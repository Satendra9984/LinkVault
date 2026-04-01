import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../objectbox.g.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/database/app_database.dart';
import '../../collections/data/mappers/collection_mapper.dart';
import '../../collections/data/mappers/supabase_collection_mapper.dart';
import '../../collections/data/models/collection_model.dart';
import '../../items/data/mappers/item_mapper.dart';
import '../../items/data/mappers/supabase_item_mapper.dart';
import '../../items/data/models/item_model.dart';
import '../../settings/data/models/app_settings_model.dart';
import '../../sync/application/sync_transient_retry.dart';

/// Cloud downgrade offboarding when a user cancels premium after migrating.
///
/// Uses LinkVault tables `lv_collections` and `lv_urls` (not Curate `collections` / `items`).
class CloudDowngradeService {
  final Logger _logger = Logger();
  final SupabaseClient _supabase;
  final Store _store;

  CloudDowngradeService({
    required SupabaseClient supabase,
    required AppDatabase appDatabase,
  })  : _supabase = supabase,
        _store = appDatabase.store;

  /// Fetches cloud rows → ObjectBox, then clears [hasMigratedToCloud] so routing
  /// returns to local repositories.
  Future<Either<Failure, void>> importFromCloud({
    void Function(double progress, String step)? onProgress,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(NetworkFailure('User not authenticated.'));
      }

      onProgress?.call(0.1, 'Fetching your collections...');
      final collectionsResponse = await withTransientRetry(
        operation: () async => _supabase
            .from('lv_collections')
            .select()
            .eq('owner_id', userId),
      );

      onProgress?.call(0.4, 'Fetching your links...');
      final urlsResponse = await withTransientRetry(
        operation: () async =>
            _supabase.from('lv_urls').select().eq('owner_id', userId),
      );

      onProgress?.call(0.7, 'Saving to device...');
      _store.runInTransaction(TxMode.write, () {
        final collectionBox = _store.box<CollectionModel>();
        final itemBox = _store.box<ItemModel>();

        for (final row in collectionsResponse) {
          final map = Map<String, dynamic>.from(row as Map);
          final entity = SupabaseCollectionMapper.fromRow(map);
          final existing = collectionBox
              .query(CollectionModel_.uid.equals(entity.id))
              .build()
              .findFirst();

          final model = CollectionMapper.toModel(entity)
            ..id = existing?.id ?? 0;
          collectionBox.put(model);
        }

        for (final row in urlsResponse) {
          final map = Map<String, dynamic>.from(row as Map);
          final entity = SupabaseItemMapper.fromRow(map);
          final existing = itemBox
              .query(ItemModel_.uid.equals(entity.id))
              .build()
              .findFirst();

          final model = ItemMapper.toModel(entity)
            ..id = existing?.id ?? 0;
          itemBox.put(model);
        }

        final settingsBox = _store.box<AppSettingsModel>();
        final settings = settingsBox.query().build().findFirst() ??
            AppSettingsModel();
        settings.hasMigratedToCloud = false;
        settingsBox.put(settings);
      });

      onProgress?.call(1.0, 'Import complete!');
      _logger.i('[CloudDowngrade] Import: ${collectionsResponse.length} collections, '
          '${urlsResponse.length} urls');
      return const Right(null);
    } catch (e, st) {
      _logger.e('[CloudDowngrade] Import failed', error: e, stackTrace: st);
      return Left(NetworkFailure('Import failed. Please try again.',
          error: e, stackTrace: st));
    }
  }

  /// Deletes remote `lv_urls` and `lv_collections` for this user (+ storage best-effort).
  Future<Either<Failure, void>> deleteRemoteData({
    void Function(double progress, String step)? onProgress,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(NetworkFailure('User not authenticated.'));
      }

      onProgress?.call(0.1, 'Deleting remote links...');
      await withTransientRetry(
        operation: () =>
            _supabase.from('lv_urls').delete().eq('owner_id', userId),
      );

      onProgress?.call(0.4, 'Deleting remote collections...');
      await withTransientRetry(
        operation: () => _supabase
            .from('lv_collections')
            .delete()
            .eq('owner_id', userId),
      );

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
