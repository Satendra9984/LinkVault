
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../objectbox.g.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/database/app_database.dart';
import '../../collections/data/models/collection_model.dart';
import '../../items/data/models/item_model.dart';
import '../../items/domain/entities/item.dart' show ItemStatus;
import '../../settings/data/models/app_settings_model.dart';

/// Handles the **cloud downgrade offboarding** flow when a user cancels their
/// subscription after having migrated data to the cloud.
///
/// Two flows:
/// - [importFromCloud]: Fetch all Supabase data → write to local ObjectBox →
///   reset [hasMigratedToCloud] flag. User becomes a local-only freemium user.
/// - [deleteRemoteData]: Permanently wipe all Supabase data + Storage files
///   for this user. Irreversible — must be confirmed by the user in the UI.
class CloudDowngradeService {
  final Logger _logger = Logger();
  final SupabaseClient _supabase;
  final Store _store;

  CloudDowngradeService({
    required SupabaseClient supabase,
    required AppDatabase appDatabase,
  })  : _supabase = supabase,
        _store = appDatabase.store;

  // ── Import from Cloud ───────────────────────────────────────────────────────

  /// Fetches all of the user's data from Supabase and writes it to the local
  /// ObjectBox store. Sets [hasMigratedToCloud] to `false` at the end so the
  /// repository providers switch back to the local repository.
  ///
  /// This is safe to retry — ObjectBox puts by UID will overwrite existing rows.
  Future<Either<Failure, void>> importFromCloud({
    void Function(double progress, String step)? onProgress,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(NetworkFailure('User not authenticated.'));
      }

      onProgress?.call(0.1, 'Fetching your collections...');
      final collectionsResponse = await _supabase
          .from('collections')
          .select()
          .eq('owner_id', userId);

      onProgress?.call(0.4, 'Fetching your items...');
      final itemsResponse = await _supabase
          .from('items')
          .select()
          .eq('owner_id', userId);

      onProgress?.call(0.7, 'Saving to device...');
      _store.runInTransaction(TxMode.write, () {
        final collectionBox = _store.box<CollectionModel>();
        final itemBox = _store.box<ItemModel>();

        for (final row in collectionsResponse) {
          // Check if already exists in ObjectBox by uid
          final existing = collectionBox
              .query(CollectionModel_.uid.equals(row['id'] as String))
              .build()
              .findFirst();

          final model = CollectionModel()
            ..id = existing?.id ?? 0
            ..uid = row['id'] as String
            ..ownerId = row['owner_id'] as String?
            ..title = row['name'] ?? row['title'] ?? 'Untitled'
            ..category = row['category'] ?? 'General'
            ..colorHex = row['color'] ?? row['color_hex'] ?? '#000000'
            ..iconName = row['icon'] ?? row['icon_name'] ?? 'folder'
            ..position = (row['position'] as num?)?.toDouble() ??
                DateTime.now().millisecondsSinceEpoch.toDouble()
            ..itemCount = row['item_count'] ?? 0
            ..createdAt = DateTime.tryParse(row['created_at'] ?? '') ??
                DateTime.now()
            ..updatedAt = DateTime.tryParse(row['updated_at'] ?? '') ??
                DateTime.now();
          collectionBox.put(model);
        }

        for (final row in itemsResponse) {
          final existing = itemBox
              .query(ItemModel_.uid.equals(row['id'] as String))
              .build()
              .findFirst();

          final model = ItemModel()
            ..id = existing?.id ?? 0
            ..uid = row['id'] as String
            ..ownerId = row['owner_id'] as String?
            ..title = row['title'] ?? ''
            ..description = row['description']
            ..imagePath = null // Local path won't exist for cloud images
            ..imageUrl = row['image_url']
            ..link = row['link']
            ..location = row['location']
            ..tags = row['tags']
            ..dbStatus = (ItemStatus.values
                    .firstWhere((e) => e.name == row['status'],
                        orElse: () => ItemStatus.pending))
                .index
            ..collectionUid = row['collection_id'] as String? ?? ''
            ..position = (row['position'] as num?)?.toDouble() ?? 0.0
            ..createdAt = DateTime.tryParse(row['created_at'] ?? '') ??
                DateTime.now()
            ..updatedAt = DateTime.tryParse(row['updated_at'] ?? '') ??
                DateTime.now();
          itemBox.put(model);
        }

        // Reset migration flag so providers switch back to local repository
        final settingsBox = _store.box<AppSettingsModel>();
        final settings = settingsBox.query().build().findFirst() ??
            AppSettingsModel();
        settings.hasMigratedToCloud = false;
        settingsBox.put(settings);
      });

      onProgress?.call(1.0, 'Import complete!');
      _logger.i('[CloudDowngrade] Import succeeded: '
          '${collectionsResponse.length} collections, '
          '${itemsResponse.length} items');
      return const Right(null);
    } catch (e, st) {
      _logger.e('[CloudDowngrade] Import failed', error: e, stackTrace: st);
      return Left(NetworkFailure('Import failed. Please try again.',
          error: e, stackTrace: st));
    }
  }

  // ── Delete Remote Data ──────────────────────────────────────────────────────

  /// Permanently deletes all of the user's data from Supabase (collections,
  /// items, and Storage images). Also resets the local [hasMigratedToCloud]
  /// flag, making future app sessions run fully local.
  ///
  /// ⚠️ This is irreversible. Always require a typed confirmation in the UI.
  Future<Either<Failure, void>> deleteRemoteData({
    void Function(double progress, String step)? onProgress,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(NetworkFailure('User not authenticated.'));
      }

      onProgress?.call(0.1, 'Deleting remote items...');
      await _supabase.from('items').delete().eq('owner_id', userId);

      onProgress?.call(0.4, 'Deleting remote collections...');
      await _supabase.from('collections').delete().eq('owner_id', userId);

      onProgress?.call(0.7, 'Removing uploaded images...');
      try {
        final storageFiles = await _supabase.storage
            .from('item-images')
            .list(path: userId);
        if (storageFiles.isNotEmpty) {
          final paths =
              storageFiles.map((f) => '$userId/${f.name}').toList();
          await _supabase.storage.from('item-images').remove(paths);
        }
      } catch (e) {
        // Non-fatal: bucket might be empty or not yet created
        _logger.w('[CloudDowngrade] Storage cleanup skipped: $e');
      }

      onProgress?.call(0.9, 'Updating local settings...');
      _store.runInTransaction(TxMode.write, () {
        final settingsBox = _store.box<AppSettingsModel>();
        final settings = settingsBox.query().build().findFirst() ??
            AppSettingsModel();
        settings.hasMigratedToCloud = false;
        settingsBox.put(settings);
      });

      onProgress?.call(1.0, 'Remote data deleted.');
      _logger.i('[CloudDowngrade] Remote data deleted for userId=$userId');
      return const Right(null);
    } catch (e, st) {
      _logger.e('[CloudDowngrade] Delete failed', error: e, stackTrace: st);
      return Left(
          NetworkFailure('Failed to delete remote data. Please try again.',
              error: e, stackTrace: st));
    }
  }
}
