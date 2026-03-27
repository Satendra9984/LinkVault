import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/errors/supabase_quota_messages.dart';
import '../mappers/supabase_collection_mapper.dart';
import '../../domain/collection_display_defaults.dart';
import '../../domain/entities/collection.dart';
import '../../domain/library_root_collection.dart';
import '../../domain/collection_sibling_order.dart';
import '../../domain/repositories/i_collections_repository.dart';

class SupabaseCollectionRepository implements ICollectionsRepository {
  final SupabaseClient _supabase;
  final String? _userId;
  static final Map<String, Future<Either<Failure, Collection>>> _ensureInFlight =
      {};
  static int _ensureAttempts = 0;
  static int _ensureSuccesses = 0;
  static int _ensureFailures = 0;
  static int _ensureConflictFallbacks = 0;

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
      final allRes = await getAllCollections();
      final guard = allRes.fold<Failure?>((_) => null, (list) {
        Collection? target;
        for (final c in list) {
          if (c.id == id) {
            target = c;
            break;
          }
        }
        if (target != null &&
            !target.isDeleted &&
            (target.parentId == null || target.parentId!.trim().isEmpty)) {
          return const ValidationFailure(
            'Top-level collections cannot be deleted directly. Repair library root first.',
          );
        }
        final rootId = LibraryRootCollection.libraryRootIdIfExactlyOne(list);
        if (rootId != null && id == rootId) {
          return const ValidationFailure(
            'The Library folder cannot be deleted.',
          );
        }
        return null;
      });
      if (guard != null) return Left(guard);

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

  Collection _newLibraryRootEntity(String id) {
    final now = DateTime.now();
    return Collection(
      id: id,
      ownerId: _userId,
      title: LibraryRootCollection.defaultTitle,
      category: LibraryRootCollection.defaultCategory,
      colorHex: '#6366F1',
      iconName: LibraryRootCollection.defaultIcon,
      position: 0,
      createdAt: now,
      updatedAt: now,
      itemsLayout: CollectionLayoutMode.list,
      childCollectionsLayout: CollectionLayoutMode.list,
      itemsSortDefault: CollectionItemsSortDefault.manual,
      openLinksIn: CollectionOpenLinksIn.inApp,
      showLinkPreviews: true,
      parentId: null,
    );
  }

  Future<void> _repairLegacyRootItemsRemote() async {
    // `lv_urls.collection_id` is uuid; PostgREST rejects filtering by 'root'/'ROOT'.
    // Legacy string ids are repaired in local ObjectBox only. Use a SQL migration if
    // cloud rows ever need reparenting from invalid values.
  }

  Future<Either<Failure, Collection>> _readExistingRoot(String userId) async {
    try {
      final allRes = await getAllCollections();
      final collections = allRes.fold((_) => <Collection>[], (list) => list);
      final tops = collections
          .where((c) =>
              !c.isDeleted &&
              (c.parentId == null || c.parentId!.trim().isEmpty))
          .toList();
      if (tops.isEmpty) {
        AppLogger.w(
            '[collections] ensureLibraryRoot supabase: no root while recovering existing');
        return const Left(DatabaseFailure('Failed to resolve library root'));
      }
      if (tops.length > 1) {
        AppLogger.w(
            '[collections] ensureLibraryRoot supabase: ambiguous roots while recovering n=${tops.length}');
      }
      tops.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final existing = tops.first;
      AppLogger.d(
          '[collections] ensureLibraryRoot supabase: recovered existing ${existing.id}');
      return Right(existing);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e(
          '[collections] ensureLibraryRoot supabase read-existing failed',
          e,
          stackTrace);
      return Left(mapSupabaseQuotaException(
        e,
        stackTrace,
        fallbackMessage: 'Failed to ensure library root',
      ));
    }
  }

  Future<Either<Failure, Collection>> _doEnsureLibraryRootRpc(
      String userId) async {
    final ensuredIdRaw = await _supabase.rpc(
      'ensure_library_root',
      params: {'p_owner_id': userId},
    );
    final ensuredId = ensuredIdRaw?.toString();
    if (ensuredId == null || ensuredId.isEmpty) {
      return const Left(DatabaseFailure('Failed to resolve library root'));
    }
    final row = await _supabase
        .from('lv_collections')
        .select()
        .eq('id', ensuredId)
        .eq('owner_id', userId)
        .maybeSingle();
    if (row == null) {
      return const Left(DatabaseFailure('Failed to resolve library root'));
    }
    final root = _fromMap(row);
    AppLogger.d('[collections] ensureLibraryRoot supabase rpc: ${root.id}');
    return Right(root);
  }

  Future<Either<Failure, Collection>> _doEnsureLibraryRootLegacy(
      String userId) async {
    try {
      final allRes = await getAllCollections();
      final collections = allRes.fold((_) => <Collection>[], (list) => list);
      final tops = collections
          .where((c) =>
              !c.isDeleted &&
              (c.parentId == null || c.parentId!.trim().isEmpty))
          .toList();

      if (tops.length > 1) {
        final newId = const Uuid().v4();
        final root = _newLibraryRootEntity(newId);
        final insertData = SupabaseCollectionMapper.toJson(root, userId);
        await _supabase.from('lv_collections').insert(insertData);
        final now = DateTime.now().toUtc().toIso8601String();
        for (final c in tops) {
          await _supabase.from('lv_collections').update({
            'parent_id': newId,
            'updated_at': now,
          }).eq('id', c.id).eq('owner_id', userId);
        }
        await _repairLegacyRootItemsRemote();
        AppLogger.d(
            '[collections] ensureLibraryRoot supabase: created $newId reparented=${tops.length}');
        return Right(root);
      }
      if (tops.length == 1) {
        final root = tops.single;
        await _repairLegacyRootItemsRemote();
        AppLogger.d(
            '[collections] ensureLibraryRoot supabase: existing ${root.id}');
        return Right(root);
      }

      final newId = const Uuid().v4();
      final root = _newLibraryRootEntity(newId);
      final data = SupabaseCollectionMapper.toJson(root, userId);
      await _supabase.from('lv_collections').insert(data);
      await _repairLegacyRootItemsRemote();
      AppLogger.d('[collections] ensureLibraryRoot supabase: created $newId');
      return Right(root);
    } on PostgrestException catch (e, stackTrace) {
      if (e.code == '23505') {
        // Another concurrent insert won the race; reuse existing root.
        _ensureConflictFallbacks++;
        return _readExistingRoot(userId);
      }
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e('[collections] ensureLibraryRoot supabase:', e, stackTrace);
      return Left(mapSupabaseQuotaException(
        e,
        stackTrace,
        fallbackMessage: 'Failed to ensure library root',
      ));
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      AppLogger.e('[collections] ensureLibraryRoot supabase:', e, stackTrace);
      return Left(mapSupabaseQuotaException(
        e,
        stackTrace,
        fallbackMessage: 'Failed to ensure library root',
      ));
    }
  }

  Future<Either<Failure, Collection>> _doEnsureLibraryRoot(
      String userId) async {
    try {
      final rpcResult = await _doEnsureLibraryRootRpc(userId);
      return rpcResult;
    } catch (e, stackTrace) {
      AppLogger.w(
          '[collections] ensureLibraryRoot supabase: rpc fallback to legacy path (${e.runtimeType})');
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return _doEnsureLibraryRootLegacy(userId);
    }
  }

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() {
    final userId = _userId;
    if (userId == null) {
      AppLogger.w('[collections] ensureLibraryRoot supabase: no userId');
      return Future.value(const Left(NetworkFailure('User not authenticated')));
    }
    _ensureAttempts++;
    final started = DateTime.now();
    return _ensureInFlight.putIfAbsent(userId, () async {
      try {
        final result = await _doEnsureLibraryRoot(userId);
        result.fold(
          (_) => _ensureFailures++,
          (_) => _ensureSuccesses++,
        );
        return result;
      } finally {
        final elapsed = DateTime.now().difference(started).inMilliseconds;
        AppLogger.d(
            '[collections] ensureLibraryRoot supabase metrics attempts=$_ensureAttempts success=$_ensureSuccesses failed=$_ensureFailures conflictFallback=$_ensureConflictFallbacks elapsedMs=$elapsed');
        _ensureInFlight.remove(userId);
      }
    });
  }
}
