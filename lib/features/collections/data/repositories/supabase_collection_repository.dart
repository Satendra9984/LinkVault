import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
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
        return const Left(NetworkFailure('User not authenticated'));
      }
      final data = SupabaseCollectionMapper.toJson(collection, _userId);

      await _supabase.from('lv_collections').insert(data);
      return const Right(null);
    } catch (e, stackTrace) {
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
      await _supabase.from('lv_collections').delete().eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(NetworkFailure('Failed to delete collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async {
    try {
      final response = await _supabase
          .from('lv_collections')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return const Right(null);
      return Right(_fromMap(response));
    } catch (e, stackTrace) {
      return Left(NetworkFailure('Failed to get collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    try {
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }

      final data = SupabaseCollectionMapper.toJson(collection, _userId);

      await _supabase.from('lv_collections').update(data).eq('id', collection.id);
      return const Right(null);
    } catch (e, stackTrace) {
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
      await _supabase.from('lv_collections').update({
        'position': newPosition,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(NetworkFailure('Failed to update collection position',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Stream<List<Collection>> watchCollections() {
    if (_userId == null) return Stream.value([]);

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
          return list;
        });
  }

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async {
    try {
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }

      final response =
          await _supabase.from('lv_collections').select().eq('owner_id', _userId);

      final collections = (response as List<dynamic>)
          .map((data) => _fromMap(data as Map<String, dynamic>))
          .toList();

      return Right(collections);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get all collections',
          error: e, stackTrace: stackTrace));
    }
  }

  Collection _fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      ownerId: map['owner_id'],
      parentId: map['parent_id'],
      isShared: map['is_shared'] ?? false,
      title: map['title'] ?? map['name'] ?? 'Untitled',
      category: map['category'] ?? 'general',
      colorHex: map['color_hex'] ?? map['color'] ?? '#6366F1',
      iconName: map['icon_name'] ?? map['icon'] ?? 'folder',
      position: (map['position'] as num?)?.toDouble() ?? 0.0,
      isPinned: map['is_pinned'] ?? false,
      isArchived: map['is_archived'] ?? false,
      isDeleted: map['is_deleted'] ?? false,
      childCount: map['child_count'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      itemCount: map['url_count'] ?? map['item_count'] ?? 0,
    );
  }
}
