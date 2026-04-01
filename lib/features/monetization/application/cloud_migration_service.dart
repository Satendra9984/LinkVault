import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../objectbox.g.dart' hide StorageException;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/database/app_database.dart';
import '../../collections/domain/library_root_collection.dart';
import '../../collections/domain/repositories/i_collections_repository.dart';
import '../../items/data/mappers/supabase_item_mapper.dart';
import '../../items/domain/repositories/i_items_repository.dart';
import '../../settings/data/models/app_settings_model.dart';
import '../../sync/application/sync_transient_retry.dart';
import 'cloud_migration_root_alignment.dart';
import 'package:logger/logger.dart';

class CloudMigrationService {
  final Logger _logger = Logger();
  final SupabaseClient _supabase;
  final Store _store;
  final ICollectionsRepository _localCollectionsRepo;
  final IItemsRepository _localItemsRepo;

  CloudMigrationService({
    required SupabaseClient supabase,
    required AppDatabase appDatabase,
    required ICollectionsRepository localCollectionsRepo,
    required IItemsRepository localItemsRepo,
  })  : _supabase = supabase,
        _store = appDatabase.store,
        _localCollectionsRepo = localCollectionsRepo,
        _localItemsRepo = localItemsRepo;

  /// Executes the full block migration from objectbox (Local) -> Supabase (Cloud).
  /// This must run on a background thread ideally, or show a blocking UI.
  Future<Either<Failure, void>> migrateToCloud({
    required void Function(double progress, String step) onProgress,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return const Left(
            NetworkFailure('You must be logged in to migrate to the cloud.'));
      }
      final userId = user.id;

      onProgress(0.08, 'Preparing local library folder...');
      final ensureResult =
          await _localCollectionsRepo.ensureLibraryRootCollection();
      if (ensureResult.isLeft()) {
        return Left(
          ensureResult.fold((l) => l, (r) => throw StateError('unreachable')),
        );
      }

      final repairResult = await _repairExtraLocalTopLevelFolders();
      if (repairResult.isLeft()) {
        return repairResult;
      }

      onProgress(0.1, 'Reading local collections...');
      final collectionsResult = await _localCollectionsRepo.getAllCollections();
      if (collectionsResult.isLeft()) {
        return Left(collectionsResult.fold((l) => l, (r) => throw Exception()));
      }
      var collections = collectionsResult.getOrElse((_) => []);

      onProgress(0.2, 'Reading local items...');
      final itemsResult = await _localItemsRepo.getAllItems();
      // Best-effort: if items migration is unavailable (e.g. legacy schema
      // mismatch), we still want collections continuity after guest->account.
      final items = itemsResult.isLeft() ? [] : itemsResult.getOrElse((_) => []);

      // Align local root id with Supabase `ensure_library_root` so we never
      // insert a second `parent_id IS NULL` row for this user (23505).
      String? serverRootId;
      String? localRootId;
      if (collections.isNotEmpty) {
        localRootId = LibraryRootCollection.libraryRootIdIfExactlyOne(
              collections,
            ) ??
            CloudMigrationRootAlignment.canonicalTopLevelRootId(collections);
        if (localRootId == null || localRootId.isEmpty) {
          return const Left(
            DatabaseFailure(
              'Could not determine your Library folder locally. Try reopening Collections, then retry sync.',
            ),
          );
        }

        onProgress(0.25, 'Aligning with cloud library root...');
        final raw = await withTransientRetry(
          operation: () => _supabase.rpc(
            'ensure_library_root',
            params: {'p_owner_id': userId},
          ),
        );
        serverRootId = raw?.toString();
        if (serverRootId == null || serverRootId.isEmpty) {
          return const Left(
            DatabaseFailure(
              'Could not resolve your cloud Library folder. Check your connection and try again.',
            ),
          );
        }

        collections = CloudMigrationRootAlignment.collectionsWithRemappedRootIds(
          collections,
          localRootId: localRootId,
          serverRootId: serverRootId,
        );

        final sanity =
            CloudMigrationRootAlignment.toSupabaseCollectionJson(collections, userId);
        final rootRows =
            CloudMigrationRootAlignment.countActiveRootRowsInJson(sanity);
        if (rootRows != 1) {
          _logger.w(
            'CloudMigrationService: expected 1 active root row in payload, got $rootRows',
          );
          return const Left(
            DatabaseFailure(
              'Your local folder tree has multiple top-level libraries. Open Collections to repair, then retry sync.',
            ),
          );
        }
      }

      // 1. Upsert Collections (batched + transient retry — idempotent on UUID PK)
      onProgress(0.3, 'Uploading collections (${collections.length})...');
      if (collections.isNotEmpty) {
        final collectionData =
            CloudMigrationRootAlignment.toSupabaseCollectionJson(
          collections,
          userId,
        );
        const batchSize = 100;
        for (var i = 0; i < collectionData.length; i += batchSize) {
          final end = (i + batchSize < collectionData.length)
              ? i + batchSize
              : collectionData.length;
          final batch = collectionData.sublist(i, end);
          await withTransientRetry(
            operation: () =>
                _supabase.from('lv_collections').upsert(batch),
          );
        }
      }

      // 2. Upload Images for Items (Sequential to not overload memory)
      onProgress(0.5, 'Uploading images and items (${items.length})...');

      final mappedItems = [];
      try {
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          String? uploadedImageUrl = item.imageUrl;

          // Upload new image if local imagePath exists and is not an http url
          if (item.imagePath != null &&
              item.imagePath!.isNotEmpty &&
              !item.imagePath!.startsWith('http')) {
            onProgress(
                0.5 + (0.3 * (items.isEmpty ? 0 : (i / items.length))),
                'Uploading image ${i + 1} of ${items.length}...');

            final file = File(item.imagePath!);
            if (await file.exists()) {
              // Use a stable, deterministic filename based only on item.id.
              // This makes uploads idempotent: re-running migration on an
              // already-migrated account won't create duplicate Storage files.
              final path = '$userId/${item.id}.jpg';
              try {
                // Attempt to get the public URL first — if the file already
                // exists, we skip the costly upload entirely.
                await _supabase.storage
                    .from('item-images')
                    .createSignedUrl(path, 60);
                uploadedImageUrl =
                    _supabase.storage.from('item-images').getPublicUrl(path);
              } catch (_) {
                // File does not exist yet — safe to upload.
                await _supabase.storage.from('item-images').upload(path, file);
                uploadedImageUrl =
                    _supabase.storage.from('item-images').getPublicUrl(path);
              }
            }
          }

          final itemForCloud = CloudMigrationRootAlignment.itemWithRemappedRootCollection(
            item,
            localRootId: localRootId,
            serverRootId: serverRootId,
          );

          mappedItems.add(
            SupabaseItemMapper.toInsertJson(
              itemForCloud,
              ownerId: userId,
              uploadedImageUrl: uploadedImageUrl,
            ),
          );
        }
      } catch (e) {
        // If legacy items schema doesn't exist yet (Sprint gap), skip items.
        _logger.w('CloudMigrationService: skipping item migration: $e');
      }

      // 3. Upsert Items
      onProgress(0.9, 'Finalizing items sync...');
      if (mappedItems.isNotEmpty) {
        try {
          // Upsert in batches of 100 to avoid request too large errors
          for (var i = 0; i < mappedItems.length; i += 100) {
            final end =
                (i + 100 < mappedItems.length) ? i + 100 : mappedItems.length;
            final batch = mappedItems.sublist(i, end);
            await withTransientRetry(
              operation: () => _supabase.from('lv_urls').upsert(
                    List<Map<String, dynamic>>.from(batch),
                  ),
            );
          }
        } catch (e) {
          // Items migration may not be ready yet (Sprint 7-8 gap); don't
          // block guest->account collections continuity.
          _logger.w('CloudMigrationService: item upsert skipped: $e');
        }
      }

      // 4. Update the Local App Settings
      onProgress(0.95, 'Activating remote cloud...');
      _store.runInTransaction(TxMode.write, () {
        final box = _store.box<AppSettingsModel>();
        var settings = box.query().build().findFirst();
        settings ??= AppSettingsModel();
        settings.hasMigratedToCloud = true;
        box.put(settings);
      });

      onProgress(1.0, 'Migration Complete!');
      return const Right(null);
    } catch (e, stackTrace) {
      _logger.e('Cloud Migration Failed', error: e, stackTrace: stackTrace);

      String safeMessage = 'An unexpected error occurred during sync.';
      if (e is PostgrestException) {
        safeMessage = 'Database error: Please check if your app is up to date.';
      } else if (e is SocketException) {
        safeMessage = 'Network error. Please check your connection.';
      } else if (e is StorageException) {
        safeMessage = e.message.contains('Bucket not found')
            ? 'Storage bucket "item-images" missing in Supabase. Please create it and set it to public.'
            : 'Storage error: ${e.message}';
      }

      return Left(
          DatabaseFailure(safeMessage, error: e, stackTrace: stackTrace));
    }
  }

  /// Reparents extra non-deleted top-level folders under the canonical root.
  Future<Either<Failure, void>> _repairExtraLocalTopLevelFolders() async {
    final collectionsResult = await _localCollectionsRepo.getAllCollections();
    if (collectionsResult.isLeft()) {
      return Left(collectionsResult.fold((l) => l, (r) => throw Exception()));
    }
    final all = collectionsResult.getOrElse((_) => []);
    final tops = all
        .where(
          (c) =>
              !c.isDeleted &&
              (c.parentId == null || c.parentId!.trim().isEmpty),
        )
        .toList();
    if (tops.length <= 1) return const Right(null);

    final canonical = CloudMigrationRootAlignment.canonicalTopLevelRootId(all);
    if (canonical == null || canonical.isEmpty) {
      return const Left(
        DatabaseFailure(
          'Could not repair multiple top-level folders. Open Collections and try again.',
        ),
      );
    }

    for (final t in tops) {
      if (t.id == canonical) continue;
      final patched = CloudMigrationRootAlignment.withParentId(t, canonical);
      final updateResult =
          await _localCollectionsRepo.updateCollection(patched);
      if (updateResult.isLeft()) {
        return Left(updateResult.fold((l) => l, (r) => throw Exception()));
      }
    }
    return const Right(null);
  }

}
