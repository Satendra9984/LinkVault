import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/errors/supabase_quota_messages.dart';
import '../mappers/supabase_collection_mapper.dart';
import '../../domain/entities/collection.dart';
import '../../domain/collection_sibling_order.dart';
import '../../domain/repositories/i_collections_repository.dart';

class SupabaseCollectionRepository implements ICollectionsRepository {
  final SupabaseClient _supabase;
  final String? _userId;

  SupabaseCollectionRepository(this._supabase, {String? userId})
      : _userId = userId ?? _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    try {
      if (_userId == null) {
        AppLogger.w('[collections] createCollection: no userId');
        return const Left(NetworkFailure('User not authenticated'));
      }
      AppLogger.d(
          '[collections] createCollection supabase title="${collection.title}" parent=${collection.parentId}');
      final data = SupabaseCollectionMapper.toJson(collection, _userId);

      await _supabase.from('lv_collections').insert(data);
      AppLogger.d('[collections] createCollection supabase ok');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] createCollection supabase failed', e, stackTrace);
      return Left(mapSupabaseQuotaException(
        e,
        stackTrace,
        fallbackMessage: 'Failed to create collection',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async {
    try {
      AppLogger.d('[collections] deleteCollection supabase id=$id');
      await _supabase.from('lv_collections').delete().eq('id', id);
      AppLogger.d('[collections] deleteCollection supabase ok id=$id');
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure =
          tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e('[collections] deleteCollection supabase failed id=$id', e, stackTrace);
      return Left(NetworkFailure('Failed to delete collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async {
    try {
      AppLogger.d('[collections] getCollectionById supabase id=$id');
      final response = await _supabase
          .from('lv_collections')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        AppLogger.d('[collections] getCollectionById supabase not found id=$id');
        return const Right(null);
      }
      AppLogger.d('[collections] getCollectionById supabase ok id=$id');
      return Right(_fromMap(response));
    } catch (e, stackTrace) {
      final authFailure =
          tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e('[collections] getCollectionById supabase failed id=$id', e, stackTrace);
      return Left(NetworkFailure('Failed to get collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    try {
      if (_userId == null) {
        AppLogger.w('[collections] updateCollection supabase: no userId');
        return const Left(NetworkFailure('User not authenticated'));
      }

      AppLogger.d(
          '[collections] updateCollection supabase id=${collection.id} title="${collection.title}"');
      final data = SupabaseCollectionMapper.toJson(collection, _userId);

      await _supabase.from('lv_collections').update(data).eq('id', collection.id);
      AppLogger.d('[collections] updateCollection supabase ok id=${collection.id}');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] updateCollection supabase failed id=${collection.id}', e, stackTrace);
      return Left(mapSupabaseQuotaException(
        e,
        stackTrace,
        fallbackMessage: 'Failed to update collection',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
      String id, double newPosition) async {
    try {
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }
      AppLogger.d(
          '[collections] updateCollectionPosition supabase id=$id position=$newPosition');
      await _supabase.from('lv_collections').update({
        'position': newPosition,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure =
          tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e('[collections] updateCollectionPosition supabase failed id=$id', e, stackTrace);
      return Left(NetworkFailure('Failed to update collection position',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Stream<List<Collection>> watchCollections() {
    if (_userId == null) {
      AppLogger.w('[collections] watchCollections supabase: no userId, empty stream');
      return Stream.value([]);
    }

    AppLogger.d('[collections] watchCollections supabase subscribed owner=$_userId');
    return _supabase
        .from('lv_collections')
        .stream(primaryKey: ['id'])
        .eq('owner_id', _userId)
        .order('is_archived', ascending: true)
        .order('is_pinned', ascending: false)
        .order('position', ascending: true)
        .map((data) {
          final list = data.map((json) => _fromMap(json)).toList();
          sortCollectionsSiblings(list);
          AppLogger.t('[collections] watchCollections supabase emit n=${list.length}');
          return list;
        });
  }

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async {
    try {
      if (_userId == null) {
        AppLogger.w('[collections] getAllCollections supabase: no userId');
        return const Left(NetworkFailure('User not authenticated'));
      }

      final response =
          await _supabase.from('lv_collections').select().eq('owner_id', _userId);

      final collections = (response as List<dynamic>)
          .map((data) => _fromMap(data as Map<String, dynamic>))
          .toList();

      AppLogger.d('[collections] getAllCollections supabase n=${collections.length}');
      return Right(collections);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] getAllCollections supabase failed', e, stackTrace);
      return Left(DatabaseFailure('Failed to get all collections',
          error: e, stackTrace: stackTrace));
    }
  }

  Collection _fromMap(Map<String, dynamic> map) =>
      SupabaseCollectionMapper.fromRow(map);

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) async {
    try {
      if (_userId == null) {
        AppLogger.w('[collections] recordCollectionAccess: no userId');
        return const Left(NetworkFailure('User not authenticated'));
      }
      final now = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('lv_collections').update({
        'last_accessed_at': now,
        'updated_at': now,
      }).eq('id', id).eq('owner_id', _userId);
      AppLogger.t('[collections] recordCollectionAccess ok id=$id');
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure =
          tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e('[collections] recordCollectionAccess failed id=$id', e, stackTrace);
      return Left(NetworkFailure('Failed to record collection access',
          error: e, stackTrace: stackTrace));
    }
  }
}
