// lib/features/urls/data/datasources/urls_local_data_source.dart

import 'package:isar/isar.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/src/urls_store/data/models/url_model.dart';


abstract class UrlsLocalDataSource {
  // CRUD Operations
  Future<UrlModel> createUrl(UrlModel url);
  Future<UrlModel?> getUrl(String id);
  Future<List<UrlModel>> getUrlsByCollection(
    String collectionId, {
    bool includeArchived = false,
  });
  Future<UrlModel> updateUrl(UrlModel url);
  Future<void> deleteUrl(String id);

  // Batch Operations
  Future<List<UrlModel>> createUrls(List<UrlModel> urls);
  Future<void> deleteUrls(List<String> ids);
  Future<List<UrlModel>> moveUrls(List<String> urlIds, String targetCollectionId);

  // Favorites & Pins
  Future<UrlModel> togglePin(String id);
  Future<List<UrlModel>> getPinnedUrls();
  Future<List<UrlModel>> getPinnedUrlsByCollection(String collectionId);

  // Archiving
  Future<UrlModel> toggleArchive(String id);
  Future<List<UrlModel>> getArchivedUrls();

  // Analytics & Interaction
  Future<UrlModel> incrementClickCount(String id);
  Future<UrlModel> updateLastAccessed(String id);
  Future<List<UrlModel>> getMostVisitedUrls({int limit = 10});

  // Positioning
  Future<UrlModel> updatePosition(String id, int newPosition);
  Future<void> reorderUrls(String collectionId, List<String> orderedIds);

  // Metadata & Enrichment
  Future<UrlModel> updateMetadata(String id, Map<String, dynamic> metadata);

  // Search & Filter
  Future<List<UrlModel>> searchUrls(String query);
  Future<List<UrlModel>> getUrlsByTag(String tagId);
  Future<List<UrlModel>> getRecentUrls({int limit = 20});

  // Utility
  Future<void> clearAllUrls();
  Future<int> getUrlsCount();
  Future<bool> urlExists(String id);
}

class UrlsLocalDataSourceImpl implements UrlsLocalDataSource {
  final Isar _isar;

  const UrlsLocalDataSourceImpl(this._isar);

  @override
  Future<UrlModel> createUrl(UrlModel url) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.urlModels.put(url);
      });
      return url;
    } catch (e) {
      throw CacheException(
        message: 'Failed to create URL: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel?> getUrl(String id) async {
    try {
      return await _isar.urlModels.filter().idEqualTo(id).findFirst();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get URL: ${e.toString()}',
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
      var query = _isar.urlModels
          .filter()
          .collectionIdEqualTo(collectionId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      return await query.sortByPosition().findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get URLs by collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updateUrl(UrlModel url) async {
    try {
      final updatedUrl = url.copyWith(updatedAt: DateTime.now());
      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });
      return updatedUrl;
    } catch (e) {
      throw CacheException(
        message: 'Failed to update URL: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteUrl(String id) async {
    try {
      await _isar.writeTxn(() async {
        final deleted = await _isar.urlModels.filter().idEqualTo(id).deleteFirst();
        if (!deleted) {
          throw CacheException(
            message: 'URL not found with id: $id',
            statusCode: 404,
          );
        }
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to delete URL: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> createUrls(List<UrlModel> urls) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.urlModels.putAll(urls);
      });
      return urls;
    } catch (e) {
      throw CacheException(
        message: 'Failed to create URLs in batch: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteUrls(List<String> ids) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.urlModels.filter().anyOf(ids, (q, id) => q.idEqualTo(id)).deleteAll();
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete URLs in batch: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> moveUrls(List<String> urlIds, String targetCollectionId) async {
    try {
      final urls = await _isar.urlModels
          .filter()
          .anyOf(urlIds, (q, id) => q.idEqualTo(id))
          .findAll();
      
      if (urls.length != urlIds.length) {
        throw CacheException(
          message: 'Some URLs not found for moving',
          statusCode: 404,
        );
      }

      final updatedUrls = urls
          .map((url) => url.copyWith(
                collectionId: targetCollectionId,
                updatedAt: DateTime.now(),
              ))
          .toList();

      await _isar.writeTxn(() async {
        await _isar.urlModels.putAll(updatedUrls);
      });

      return updatedUrls;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to move URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> togglePin(String id) async {
    try {
      final url = await getUrl(id);
      if (url == null) {
        throw CacheException(
          message: 'URL not found with id: $id',
          statusCode: 404,
        );
      }

      final updatedUrl = url.copyWith(
        isPinned: !url.isPinned,
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });

      return updatedUrl;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to toggle pin for URL: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getPinnedUrls() async {
    try {
      return await _isar.urlModels
          .filter()
          .isPinnedEqualTo(true)
          .isArchivedEqualTo(false)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get pinned URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getPinnedUrlsByCollection(String collectionId) async {
    try {
      return await _isar.urlModels
          .filter()
          .collectionIdEqualTo(collectionId)
          .and()
          .isPinnedEqualTo(true)
          .and()
          .isArchivedEqualTo(false)
          .sortByPosition()
          .findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get pinned URLs for collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> toggleArchive(String id) async {
    try {
      final url = await getUrl(id);
      if (url == null) {
        throw CacheException(
          message: 'URL not found with id: $id',
          statusCode: 404,
        );
      }

      final updatedUrl = url.copyWith(
        isArchived: !url.isArchived,
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });

      return updatedUrl;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to toggle archive for URL: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getArchivedUrls() async {
    try {
      return await _isar.urlModels
          .filter()
          .isArchivedEqualTo(true)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get archived URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> incrementClickCount(String id) async {
    try {
      final url = await getUrl(id);
      if (url == null) {
        throw CacheException(
          message: 'URL not found with id: $id',
          statusCode: 404,
        );
      }

      final updatedUrl = url.copyWith(
        clickCount: url.clickCount + 1,
        lastAccessedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });

      return updatedUrl;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to increment click count: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updateLastAccessed(String id) async {
    try {
      final url = await getUrl(id);
      if (url == null) {
        throw CacheException(
          message: 'URL not found with id: $id',
          statusCode: 404,
        );
      }

      final updatedUrl = url.copyWith(
        lastAccessedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });

      return updatedUrl;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update last accessed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getMostVisitedUrls({int limit = 10}) async {
    try {
      return await _isar.urlModels
          .filter()
          .isArchivedEqualTo(false)
          .sortByClickCountDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get most visited URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updatePosition(String id, int newPosition) async {
    try {
      final url = await getUrl(id);
      if (url == null) {
        throw CacheException(
          message: 'URL not found with id: $id',
          statusCode: 404,
        );
      }

      final updatedUrl = url.copyWith(
        position: newPosition,
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });

      return updatedUrl;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update URL position: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> reorderUrls(String collectionId, List<String> orderedIds) async {
    try {
      final urls = await _isar.urlModels
          .filter()
          .collectionIdEqualTo(collectionId)
          .and()
          .anyOf(orderedIds, (q, id) => q.idEqualTo(id))
          .findAll();

      if (urls.length != orderedIds.length) {
        throw CacheException(
          message: 'Some URLs not found for reordering',
          statusCode: 404,
        );
      }

      final updatedUrls = <UrlModel>[];
      for (int i = 0; i < orderedIds.length; i++) {
        final url = urls.firstWhere((u) => u.id == orderedIds[i]);
        updatedUrls.add(url.copyWith(
          position: i,
          updatedAt: DateTime.now(),
        ));
      }

      await _isar.writeTxn(() async {
        await _isar.urlModels.putAll(updatedUrls);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to reorder URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UrlModel> updateMetadata(String id, Map<String, dynamic> metadata) async {
    try {
      final url = await getUrl(id);
      if (url == null) {
        throw CacheException(
          message: 'URL not found with id: $id',
          statusCode: 404,
        );
      }

      final updatedUrl = url.copyWith(
        // metadata: metadata,
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.urlModels.put(updatedUrl);
      });

      return updatedUrl;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update URL metadata: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> searchUrls(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      return await _isar.urlModels
          .filter()
          .group((q) => q
              .titleContains(lowerQuery, caseSensitive: false)
              .or()
              .urlContains(lowerQuery, caseSensitive: false)
              .or()
              .descriptionContains(lowerQuery, caseSensitive: false))
          .and()
          .isArchivedEqualTo(false)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to search URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getUrlsByTag(String tagId) async {
    try {
      // Note: This would require a relationship setup in Isar
      // For now, we'll return an empty list as the tag relationship
      // would be handled at the repository level by cross-referencing tables
      return [];
    } catch (e) {
      throw CacheException(
        message: 'Failed to get URLs by tag: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<UrlModel>> getRecentUrls({int limit = 20}) async {
    try {
      return await _isar.urlModels
          .filter()
          .isArchivedEqualTo(false)
          .and()
          .lastAccessedAtIsNotNull()
          .sortByLastAccessedAtDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> clearAllUrls() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.urlModels.clear();
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all URLs: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<int> getUrlsCount() async {
    try {
      return await _isar.urlModels.count();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get URLs count: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> urlExists(String id) async {
    try {
      final url = await _isar.urlModels.filter().idEqualTo(id).findFirst();
      return url != null;
    } catch (e) {
      throw CacheException(
        message: 'Failed to check if URL exists: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}