// lib/features/collections/data/datasources/collections_local_data_source.dart

import 'package:isar/isar.dart';
import '../models/collection_model.dart';

abstract class CollectionsLocalDataSource {
  // CRUD Operations
  Future<CollectionModel> createCollection(CollectionModel collection);
  Future<CollectionModel?> getCollection(String id);
  Future<List<CollectionModel>> getAllCollections({
    String? parentCollectionId,
    bool includeArchived = false,
  });
  Future<CollectionModel> updateCollection(CollectionModel collection);
  Future<void> deleteCollection(String id);

  // Hierarchical Operations
  Future<List<CollectionModel>> getChildCollections(String parentId);
  Future<List<CollectionModel>> getRootCollections();
  Future<bool> canMoveCollection(String collectionId, String? newParentId);
  Future<CollectionModel> moveCollection(String collectionId, String? newParentId);

  // Favorites & Pins
  Future<CollectionModel> togglePin(String id);
  Future<List<CollectionModel>> getPinnedCollections();

  // Archiving
  Future<CollectionModel> toggleArchive(String id);
  Future<List<CollectionModel>> getArchivedCollections();

  // Ordering & Layout
  Future<CollectionModel> updatePosition(String id, int newPosition);
  Future<CollectionModel> updateLayout(String id, String layoutType);
  Future<CollectionModel> updateSortOrder(String id, String sortOrder);

  // Statistics & Analytics
  Future<CollectionModel> updateLastAccessed(String id);
  Future<void> refreshCollectionStats(String id);

  // Search & Filter
  Future<List<CollectionModel>> searchCollections(String query);
  Future<List<CollectionModel>> getCollectionsByCategory(String categoryId);
  Future<List<CollectionModel>> getCollectionsByTag(String tagId);

  // Batch Operations
  Future<List<CollectionModel>> saveCollections(List<CollectionModel> collections);
  Future<void> deleteCollections(List<String> ids);
  Future<void> clearAllCollections();

  // Sync Operations
  Future<List<CollectionModel>> getAllCollectionsForSync();
  Future<DateTime?> getLastSyncTimestamp();
  Future<void> setLastSyncTimestamp(DateTime timestamp);
}

class CollectionsLocalDataSourceImpl implements CollectionsLocalDataSource {
  final Isar isar;

  CollectionsLocalDataSourceImpl({required this.isar});

  @override
  Future<CollectionModel> createCollection(CollectionModel collection) async {
    try {
      await isar.writeTxn(() async {
        await isar.collectionModels.put(collection);
      });
      
      final savedCollection = await isar.collectionModels.put(collection);
      
      return savedCollection;
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to create collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel?> getCollection(String id) async {
    try {
      return await isar.collectionModels
          .filter()
          .idEqualTo(id)
          .findFirst();
    } catch (e) {
      throw LocalDataException(
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
      var query = isar.collectionModels.filter();
      
      // Filter by parent collection
      if (parentCollectionId != null) {
        query = query.parentCollectionIdEqualTo(parentCollectionId);
      } else {
        query = query.parentCollectionIdIsNull();
      }
      
      // Filter archived collections
      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }
      
      return await query
          .sortByPosition()
          .thenByCreatedAt()
          .findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateCollection(CollectionModel collection) async {
    try {
      final existingCollection = await getCollection(collection.id);
      if (existingCollection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      // Update the updatedAt timestamp
      final updatedCollection = collection.copyWith(
        updatedAt: DateTime.now(),
      );

      await isar.writeTxn(() async {
        await isar.collectionModels.put(updatedCollection);
      });

      final savedCollection = await getCollection(collection.id);
      return savedCollection!;
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to update collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      await isar.writeTxn(() async {
        // Delete all child collections recursively
        final childCollections = await getChildCollections(id);
        for (final child in childCollections) {
          await deleteCollection(child.id);
        }
        
        // Delete the collection itself
        await isar.collectionModels
            .filter()
            .idEqualTo(id)
            .deleteAll();
      });
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to delete collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getChildCollections(String parentId) async {
    try {
      return await isar.collectionModels
          .filter()
          .parentCollectionIdEqualTo(parentId)
          .isArchivedEqualTo(false)
          .sortByPosition()
          .thenByCreatedAt()
          .findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get child collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getRootCollections() async {
    try {
      return await isar.collectionModels
          .filter()
          .parentCollectionIdIsNull()
          .isArchivedEqualTo(false)
          .sortByPosition()
          .thenByCreatedAt()
          .findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get root collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> canMoveCollection(String collectionId, String? newParentId) async {
    try {
      if (newParentId == null) return true;
      
      // Check if trying to move to itself
      if (collectionId == newParentId) return false;
      
      // Check if trying to move to one of its descendants
      final descendants = await _getAllDescendants(collectionId);
      return !descendants.any((d) => d.id == newParentId);
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to check move validity: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> moveCollection(String collectionId, String? newParentId) async {
    try {
      final canMove = await canMoveCollection(collectionId, newParentId);
      if (!canMove) {
        throw LocalDataException(
          message: 'Cannot move collection to specified parent',
          statusCode: 400,
        );
      }

      final collection = await getCollection(collectionId);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        parentCollectionId: newParentId,
        updatedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to move collection: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> togglePin(String id) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        isPinned: !collection.isPinned,
        updatedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to toggle pin: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getPinnedCollections() async {
    try {
      return await isar.collectionModels
          .filter()
          .isPinnedEqualTo(true)
          .isArchivedEqualTo(false)
          .sortByPosition()
          .thenByCreatedAt()
          .findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get pinned collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> toggleArchive(String id) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        isArchived: !collection.isArchived,
        updatedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to toggle archive: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getArchivedCollections() async {
    try {
      return await isar.collectionModels
          .filter()
          .isArchivedEqualTo(true)
          .sortByUpdatedAt()
          .findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get archived collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updatePosition(String id, int newPosition) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        position: newPosition,
        updatedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to update position: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateLayout(String id, String layoutType) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        layoutType: layoutType,
        updatedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to update layout: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateSortOrder(String id, String sortOrder) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        sortOrder: sortOrder,
        updatedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to update sort order: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CollectionModel> updateLastAccessed(String id) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      final updatedCollection = collection.copyWith(
        lastAccessedAt: DateTime.now(),
      );

      return await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to update last accessed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> refreshCollectionStats(String id) async {
    try {
      final collection = await getCollection(id);
      if (collection == null) {
        throw LocalDataException(
          message: 'Collection not found',
          statusCode: 404,
        );
      }

      // Note: In a real implementation, you would calculate URL count and total clicks
      // from the URLs table. For now, we just update the timestamp.
      final updatedCollection = collection.copyWith(
        updatedAt: DateTime.now(),
      );

      await updateCollection(updatedCollection);
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to refresh collection stats: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> searchCollections(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllCollections();
      }

      final searchTerm = query.toLowerCase();
      
      return await isar.collectionModels
          .filter()
          .group((q) => q
              .nameContains(searchTerm, caseSensitive: false)
              .or()
              .descriptionContains(searchTerm, caseSensitive: false))
          .isArchivedEqualTo(false)
          .sortByPosition()
          .thenByCreatedAt()
          .findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to search collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsByCategory(String categoryId) async {
    try {
      // Note: This would require a relationship with categories
      // For now, returning empty list as categories are not yet implemented
      return [];
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get collections by category: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsByTag(String tagId) async {
    try {
      // Note: This would require a relationship with tags
      // For now, returning empty list as tags are not yet implemented
      return [];
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get collections by tag: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> saveCollections(List<CollectionModel> collections) async {
    try {
      await isar.writeTxn(() async {
        await isar.collectionModels.putAll(collections);
      });

      final savedCollections = <CollectionModel>[];
      for (final collection in collections) {
        final saved = await getCollection(collection.id);
        if (saved != null) {
          savedCollections.add(saved);
        }
      }

      return savedCollections;
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to save collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteCollections(List<String> ids) async {
    try {
      await isar.writeTxn(() async {
        for (final id in ids) {
          await deleteCollection(id);
        }
      });
    } catch (e) {
      if (e is LocalDataException) rethrow;
      throw LocalDataException(
        message: 'Failed to delete collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> clearAllCollections() async {
    try {
      await isar.writeTxn(() async {
        await isar.collectionModels.clear();
      });
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to clear all collections: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<CollectionModel>> getAllCollectionsForSync() async {
    try {
      return await isar.collectionModels.where().findAll();
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get collections for sync: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    try {
      // Note: This would typically be stored in a separate sync metadata table
      // For now, returning null to indicate no previous sync
      return null;
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to get last sync timestamp: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    try {
      // Note: This would typically be stored in a separate sync metadata table
      // For now, this is a no-op
    } catch (e) {
      throw LocalDataException(
        message: 'Failed to set last sync timestamp: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Helper method to get all descendants of a collection
  Future<List<CollectionModel>> _getAllDescendants(String parentId) async {
    final descendants = <CollectionModel>[];
    final directChildren = await getChildCollections(parentId);
    
    descendants.addAll(directChildren);
    
    for (final child in directChildren) {
      final childDescendants = await _getAllDescendants(child.id);
      descendants.addAll(childDescendants);
    }
    
    return descendants;
  }
}

// Custom exception for local data operations
class LocalDataException implements Exception {
  final String message;
  final int statusCode;

  LocalDataException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'LocalDataException: $message (Status: $statusCode)';
}