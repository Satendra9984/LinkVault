// lib/features/collections/data/datasources/collections_remote_datasource.dart
import 'package:link_vault/src/urls_store/data/errors/collection_exceptions.dart';
import 'package:link_vault/src/urls_store/data/models/collection_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CollectionsRemoteDataSource {
  Future<CollectionModel> createCollection(CollectionModel collection);
  Future<CollectionModel> getCollection(String id);
  Future<List<CollectionModel>> getAllCollections({
    String? parentCollectionId,
    bool includeArchived = false,
  });
  Future<CollectionModel> updateCollection(CollectionModel collection);
  Future<void> deleteCollection(String id);
  Future<List<CollectionModel>> getChildCollections(String parentId);
  Future<List<CollectionModel>> getRootCollections();
  Future<bool> canMoveCollection(String collectionId, String? newParentId);
  Future<CollectionModel> moveCollection(
      String collectionId, String? newParentId);
  Future<CollectionModel> togglePin(String id);
  Future<List<CollectionModel>> getPinnedCollections();
  Future<CollectionModel> toggleArchive(String id);
  Future<List<CollectionModel>> getArchivedCollections();
  Future<CollectionModel> updatePosition(String id, int newPosition);
  Future<CollectionModel> updateLayout(String id, String layoutType);
  Future<CollectionModel> updateSortOrder(String id, String sortOrder);
  Future<CollectionModel> updateLastAccessed(String id);
  Future<void> refreshCollectionStats(String id);
  Future<List<CollectionModel>> searchCollections(String query);
  Future<List<CollectionModel>> getCollectionsByCategory(String categoryId);
  Future<List<CollectionModel>> getCollectionsByTag(String tagId);
}

class CollectionsRemoteDataSourceImpl implements CollectionsRemoteDataSource {
  CollectionsRemoteDataSourceImpl({
    required this.supabaseClient,
  });

  final SupabaseClient supabaseClient;

  @override
  Future<CollectionModel> createCollection(CollectionModel collection) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .insert(collection.toEntity())
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to create collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> getCollection(String id) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select()
          .eq('id', id)
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw CollectionException(
          message: 'Failed to update collection: ${e.toString()}',
          statusCode: 500,
        );
      }
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getAllCollections({
    String? parentCollectionId,
    bool includeArchived = false,
  }) async {
    try {
      var query = supabaseClient.from('collections').select();

      if (parentCollectionId != null) {
        query = query.eq('parent_collection_id', parentCollectionId);
      }

      if (!includeArchived) {
        query = query.eq('is_archived', false);
      }

      query = query.order('position').order('created_at');

      final response = await query;

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateCollection(CollectionModel collection) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .update(collection.toSupabaseJson())
          .eq('id', collection.id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw CollectionNotFoundException(
            message: 'Collection Not found', statusCode: 500);
      }
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to update collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    try {
      await supabaseClient.from('collections').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to delete collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getChildCollections(String parentId) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select()
          .eq('parent_collection_id', parentId)
          .eq('is_archived', false)
          .order('position')
          .order('created_at');

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get child collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getRootCollections() async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select()
          .is_('parent_collection_id', null)
          .eq('is_archived', false)
          .order('position')
          .order('created_at');

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get root collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> canMoveCollection(
      String collectionId, String? newParentId) async {
    try {
      // If moving to root level, always allow
      if (newParentId == null) return true;

      // Check if the new parent would create a circular dependency
      // This requires a recursive check - we'll implement a simple version
      final targetCollection = await getCollection(newParentId);

      // Basic check: ensure we're not moving a collection to itself
      if (collectionId == newParentId) return false;

      // For now, allow the move (more complex circular dependency check would be needed)
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CollectionModel> moveCollection(
      String collectionId, String? newParentId) async {
    try {
      final canMove = await canMoveCollection(collectionId, newParentId);
      if (!canMove) {
        throw CollectionHierarchyException(
          message: 'Cannot move collection - would create circular dependency',
          statusCode: 500,
        );
      }

      final response = await supabaseClient
          .from('collections')
          .update({'parent_collection_id': newParentId})
          .eq('id', collectionId)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      if (e is CollectionHierarchyException) rethrow;
      throw CollectionException(
        message: 'Failed to move collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> togglePin(String id) async {
    try {
      // First get the current state
      final current = await getCollection(id);
      final newPinState = !current.isPinned;

      final response = await supabaseClient
          .from('collections')
          .update({'is_pinned': newPinState})
          .eq('id', id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } catch (e) {
      if (e is CollectionException) rethrow;
      throw CollectionException(
        message: 'Failed to toggle pin: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getPinnedCollections() async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select()
          .eq('is_pinned', true)
          .eq('is_archived', false)
          .order('position')
          .order('created_at');

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get pinned collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> toggleArchive(String id) async {
    try {
      final current = await getCollection(id);
      final newArchiveState = !current.isArchived;

      final response = await supabaseClient
          .from('collections')
          .update({'is_archived': newArchiveState})
          .eq('id', id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } catch (e) {
      if (e is CollectionException) rethrow;
      throw CollectionException(
        message: 'Failed to toggle archive: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getArchivedCollections() async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select()
          .eq('is_archived', true)
          .order('updated_at', ascending: false);

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get archived collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updatePosition(String id, int newPosition) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .update({'position': newPosition})
          .eq('id', id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to update position: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateLayout(String id, String layoutType) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .update({'layout_type': layoutType})
          .eq('id', id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to update layout: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateSortOrder(String id, String sortOrder) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .update({'sort_order': sortOrder})
          .eq('id', id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to update sort order: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateLastAccessed(String id) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('collections')
          .update({'last_accessed_at': now})
          .eq('id', id)
          .select()
          .single();

      return CollectionModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to update last accessed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> refreshCollectionStats(String id) async {
    try {
      // The database triggers handle stat updates automatically
      // This method is here for manual refresh if needed
      await supabaseClient.rpc('refresh_collection_stats', params: {
        'collection_id': id,
      });
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to refresh collection stats: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> searchCollections(String query) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_archived', false)
          .order('name');

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to search collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsByCategory(
      String categoryId) async {
    try {
      final response = await supabaseClient
          .from('collections')
          .select('''
            *,
            collection_categories!inner(
              category_id
            )
          ''')
          .eq('collection_categories.category_id', categoryId)
          .eq('is_archived', false);

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get collections by category: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsByTag(String tagId) async {
    try {
      final response = await supabaseClient.from('collections').select('''
            *,
            collection_tags!inner(
              tag_id
            )
          ''').eq('collection_tags.tag_id', tagId).eq('is_archived', false);

      return response
          .map<CollectionModel>(
              (json) => CollectionModel.fromSupabaseJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw CollectionException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      throw CollectionException(
        message: 'Failed to get collections by tag: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
