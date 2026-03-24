import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../objectbox.g.dart' hide StorageException;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/database/app_database.dart';
import '../../collections/data/mappers/supabase_collection_mapper.dart';
import '../../collections/domain/repositories/i_collections_repository.dart';
import '../../items/data/mappers/supabase_item_mapper.dart';
import '../../items/domain/repositories/i_items_repository.dart';
import '../../settings/data/models/app_settings_model.dart';
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

      onProgress(0.1, 'Reading local collections...');
      final collectionsResult = await _localCollectionsRepo.getAllCollections();
      if (collectionsResult.isLeft()) {
        return Left(collectionsResult.fold((l) => l, (r) => throw Exception()));
      }
      final collections = collectionsResult.getOrElse((_) => []);

      onProgress(0.2, 'Reading local items...');
      final itemsResult = await _localItemsRepo.getAllItems();
      if (itemsResult.isLeft()) {
        return Left(itemsResult.fold((l) => l, (r) => throw Exception()));
      }
      final items = itemsResult.getOrElse((_) => []);

      // 1. Upsert Collections
      onProgress(0.3, 'Uploading collections (${collections.length})...');
      if (collections.isNotEmpty) {
        final collectionData = collections
            .map((c) => SupabaseCollectionMapper.toJson(c, userId))
            .toList();
        await _supabase.from('collections').upsert(collectionData);
      }

      // 2. Upload Images for Items (Sequential to not overload memory)
      onProgress(0.5, 'Uploading images and items (${items.length})...');

      final mappedItems = [];
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        String? uploadedImageUrl = item.imageUrl;

        // Upload new image if local imagePath exists and is not an http url
        if (item.imagePath != null &&
            item.imagePath!.isNotEmpty &&
            !item.imagePath!.startsWith('http')) {
          onProgress(0.5 + (0.3 * (i / items.length)),
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

        mappedItems.add(
          SupabaseItemMapper.toJson(item, uploadedImageUrl: uploadedImageUrl),
        );
      }

      // 3. Upsert Items
      onProgress(0.9, 'Finalizing items sync...');
      if (mappedItems.isNotEmpty) {
        // Upsert in batches of 100 to avoid request too large errors
        for (var i = 0; i < mappedItems.length; i += 100) {
          final end =
              (i + 100 < mappedItems.length) ? i + 100 : mappedItems.length;
          final batch = mappedItems.sublist(i, end);
          await _supabase
              .from('items')
              .upsert(List<Map<String, dynamic>>.from(batch));
        }
      }

      // 4. Update the Local App Settings
      onProgress(0.95, 'Activating remote cloud...');
      _store.runInTransaction(TxMode.write, () {
        final box = _store.box<AppSettingsModel>();
        var settings = box.query().build().findFirst();
        if (settings == null) {
          settings = AppSettingsModel();
        }
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
}
