// lib/features/urls/data/datasources/urls_remote_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/url_model.dart';

abstract class UrlsRemoteDataSource {
  Future<UrlModel> createUrl(UrlModel url);
  Future<UrlModel> getUrl(String id);
  Future<List<UrlModel>> getUrlsByCollection(
    String collectionId, {
    bool includeArchived = false,
  });
  Future<UrlModel> updateUrl(UrlModel url);
  Future<void> deleteUrl(String id);
  Future<List<UrlModel>> createUrls(List<UrlModel> urls);
  Future<void> deleteUrls(List<String> ids);
  Future<List<UrlModel>> moveUrls(List<String> urlIds, String targetCollectionId);
  Future<UrlModel> togglePin(String id);
  Future<List<UrlModel>> getPinnedUrls();
  Future<List<UrlModel>> getPinnedUrlsByCollection(String collectionId);
  Future<UrlModel> toggleArchive(String id);
  Future<List<UrlModel>> getArchivedUrls();
  Future<UrlModel> incrementClickCount(String id);
  Future<UrlModel> updateLastAccessed(String id);
  Future<List<UrlModel>> getMostVisitedUrls({int limit = 10});
  Future<UrlModel> updatePosition(String id, int newPosition);
  Future<void> reorderUrls(String collectionId, List<String> orderedIds);
  Future<UrlModel> updateMetadata(String id, Map<String, dynamic> metadata);
  Future<List<UrlModel>> searchUrls(String query);
  Future<List<UrlModel>> getUrlsByTag(String tagId);
  Future<List<UrlModel>> getRecentUrls({int limit = 20});
}

class UrlsRemoteDataSourceImpl implements UrlsRemoteDataSource {
  UrlsRemoteDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const String _tableName = 'urls';
  static const String _collectionsTable = 'collections';
  static const String _urlTagsTable = 'url_tags';

  @override
  Future<UrlModel> createUrl(UrlModel url) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(url.toSupabaseJson())
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to create URL: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> getUrl(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw UrlRemoteException(
          message: 'URL not found',
          statusCode: 404,
        );
      }
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get URL: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getUrlsByCollection(
    String collectionId, {
    bool includeArchived = false,
  }) async {
    try {
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('collection_id', collectionId)
          .order('position', ascending: true);

      if (!includeArchived) {
        query = query.eq('is_archived', false);
      }

      final response = await query;

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get URLs by collection: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updateUrl(UrlModel url) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update(url.toSupabaseJson())
          .eq('id', url.id)
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to update URL: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteUrl(String id) async {
    try {
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to delete URL: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> createUrls(List<UrlModel> urls) async {
    try {
      final urlMaps = urls.map((url) => url.toSupabaseJson()).toList();
      
      final response = await _supabaseClient
          .from(_tableName)
          .insert(urlMaps)
          .select();

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to create URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteUrls(List<String> ids) async {
    try {
      await _supabaseClient
          .from(_tableName)
          .delete()
          .in_('id', ids);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to delete URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> moveUrls(List<String> urlIds, String targetCollectionId) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update({'collection_id': targetCollectionId})
          .in_('id', urlIds)
          .select();

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to move URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> togglePin(String id) async {
    try {
      // First get current pinned status
      final currentUrl = await getUrl(id);
      final newPinnedStatus = !currentUrl.isPinned;

      final response = await _supabaseClient
          .from(_tableName)
          .update({'is_pinned': newPinnedStatus})
          .eq('id', id)
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to toggle URL pin: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getPinnedUrls() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('is_pinned', true)
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get pinned URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getPinnedUrlsByCollection(String collectionId) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('collection_id', collectionId)
          .eq('is_pinned', true)
          .eq('is_archived', false)
          .order('position', ascending: true);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get pinned URLs by collection: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> toggleArchive(String id) async {
    try {
      // First get current archived status
      final currentUrl = await getUrl(id);
      final newArchivedStatus = !currentUrl.isArchived;

      final response = await _supabaseClient
          .from(_tableName)
          .update({'is_archived': newArchivedStatus})
          .eq('id', id)
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to toggle URL archive: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getArchivedUrls() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('is_archived', true)
          .order('updated_at', ascending: false);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get archived URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> incrementClickCount(String id) async {
    try {
      final response = await _supabaseClient
          .rpc('increment_url_clicks', params: {'url_id': id});

      if (response == null) {
        throw UrlRemoteException(
          message: 'Failed to increment click count',
          statusCode: 500,
        );
      }

      // Get updated URL
      return await getUrl(id);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to increment click count: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updateLastAccessed(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update({'last_accessed_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to update last accessed: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getMostVisitedUrls({int limit = 10}) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('is_archived', false)
          .order('click_count', ascending: false)
          .limit(limit);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get most visited URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updatePosition(String id, int newPosition) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update({'position': newPosition})
          .eq('id', id)
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to update URL position: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> reorderUrls(String collectionId, List<String> orderedIds) async {
    try {
      // Update positions in batch
      final List<Map<String, dynamic>> updates = [];
      for (int i = 0; i < orderedIds.length; i++) {
        updates.add({
          'id': orderedIds[i],
          'position': i,
        });
      }

      // Use upsert to update positions
      await _supabaseClient
          .from(_tableName)
          .upsert(updates, onConflict: 'id');
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to reorder URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updateMetadata(String id, Map<String, dynamic> metadata) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update({'metadata': metadata})
          .eq('id', id)
          .select()
          .single();

      return UrlModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to update URL metadata: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> searchUrls(String query) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .or('title.ilike.%$query%,url.ilike.%$query%,description.ilike.%$query%')
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to search URLs: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getUrlsByTag(String tagId) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', _supabaseClient
              .from(_urlTagsTable)
              .select('url_id')
              .eq('tag_id', tagId))
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get URLs by tag: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getRecentUrls({int limit = 20}) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .not('last_accessed_at', 'is', null)
          .eq('is_archived', false)
          .order('last_accessed_at', ascending: false)
          .limit(limit);

      return response.map<UrlModel>((json) => UrlModel.fromSupabaseJson(json)).toList();
    } on PostgrestException catch (e) {
      throw UrlRemoteException(
        message: e.message,
        statusCode: e.code ?? 'UNKNOWN',
      );
    } catch (e) {
      throw UrlRemoteException(
        message: 'Failed to get recent URLs: $e',
        statusCode: 500,
      );
    }
  }
}

// Custom exception for URL remote operations
class UrlRemoteException implements Exception {
  UrlRemoteException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final dynamic statusCode;

  @override
  String toString() => 'UrlRemoteException: $message (Status: $statusCode)';
}