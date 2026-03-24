// lib/features/collections/data/repositories/collection_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/urls_store/data/datasources/collection_local_datasource.dart';
import 'package:link_vault/src/urls_store/data/datasources/collection_remote_datasource.dart';
import 'package:link_vault/src/urls_store/data/models/collection_model.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_entity.dart';
import 'package:link_vault/src/urls_store/domain/repository/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  const CollectionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final CollectionsRemoteDataSource remoteDataSource;
  final CollectionsLocalDataSource localDataSource;

  @override
  Future<Either<Failure, CollectionEntity>> createCollection(
      CollectionEntity collection) async {
    try {
      // Convert entity to model for data layer operations
      final collectionModel = CollectionModel.fromEntity(collection);

      // Remote-first: Create in Supabase first
      final remoteResult =
          await remoteDataSource.createCollection(collectionModel);

      // Update local cache with remote result
      await localDataSource.createCollection(remoteResult);

      // Return entity
      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> getCollection(String id) async {
    try {
      // Try to get from local cache first (for performance)
      try {
        final localCollection = await localDataSource.getCollection(id);
        if (localCollection != null) {
          return Right(localCollection.toEntity());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollection = await remoteDataSource.getCollection(id);

      // Cache the remote result
      await localDataSource.cacheCollection(remoteCollection);

      return Right(remoteCollection.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getAllCollections({
    String? parentCollectionId,
    bool includeArchived = false,
  }) async {
    try {
      // Try local first for better performance
      try {
        final localCollections = await localDataSource.getAllCollections(
          parentCollectionId: parentCollectionId,
          includeArchived: includeArchived,
        );
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections = await remoteDataSource.getAllCollections(
        parentCollectionId: parentCollectionId,
        includeArchived: includeArchived,
      );

      // Cache all remote results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> updateCollection(
      CollectionEntity collection) async {
    try {
      final collectionModel = Id.fromEntity(collection);

      // Remote-first: Update in Supabase first
      final remoteResult =
          await remoteDataSource.updateCollection(collectionModel);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async {
    try {
      // Remote-first: Delete from Supabase first
      await remoteDataSource.deleteCollection(id);

      // Remove from local cache
      await localDataSource.removeCollection(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getChildCollections(
      String parentId) async {
    try {
      // Try local first
      try {
        final localCollections =
            await localDataSource.getChildCollections(parentId);
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections =
          await remoteDataSource.getChildCollections(parentId);

      // Cache results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getRootCollections() async {
    try {
      // Try local first
      try {
        final localCollections = await localDataSource.getRootCollections();
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections = await remoteDataSource.getRootCollections();

      // Cache results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> canMoveCollection(
      String collectionId, String? newParentId) async {
    try {
      // This logic needs to prevent circular references
      final canMove =
          await remoteDataSource.canMoveCollection(collectionId, newParentId);
      return Right(canMove);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> moveCollection(
      String collectionId, String? newParentId) async {
    try {
      // Remote-first: Move in Supabase first
      final remoteResult =
          await remoteDataSource.moveCollection(collectionId, newParentId);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> togglePin(String id) async {
    try {
      // Remote-first: Toggle pin in Supabase first
      final remoteResult = await remoteDataSource.togglePin(id);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getPinnedCollections() async {
    try {
      // Try local first
      try {
        final localCollections = await localDataSource.getPinnedCollections();
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections = await remoteDataSource.getPinnedCollections();

      // Cache results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> toggleArchive(String id) async {
    try {
      // Remote-first: Toggle archive in Supabase first
      final remoteResult = await remoteDataSource.toggleArchive(id);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>>
      getArchivedCollections() async {
    try {
      // Try local first
      try {
        final localCollections = await localDataSource.getArchivedCollections();
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections = await remoteDataSource.getArchivedCollections();

      // Cache results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> updatePosition(
      String id, Id newPosition) async {
    try {
      // Remote-first: Update position in Supabase first
      final remoteResult =
          await remoteDataSource.updatePosition(id, newPosition);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> updateLayout(
      String id, CollectionLayoutType layoutType) async {
    try {
      // Remote-first: Update layout in Supabase first
      final remoteResult = await remoteDataSource.updateLayout(id, layoutType);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> updateSortOrder(
      String id, CollectionSortOrder sortOrder) async {
    try {
      // Remote-first: Update sort order in Supabase first
      final remoteResult =
          await remoteDataSource.updateSortOrder(id, sortOrder);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> updateLastAccessed(
      String id) async {
    try {
      // Remote-first: Update last accessed in Supabase first
      final remoteResult = await remoteDataSource.updateLastAccessed(id);

      // Update local cache
      await localDataSource.cacheCollection(remoteResult);

      return Right(remoteResult.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> refreshCollectionStats(String id) async {
    try {
      // Remote-first: Refresh stats in Supabase first
      await remoteDataSource.refreshCollectionStats(id);

      // Get updated collection and cache it
      final updatedCollection = await remoteDataSource.getCollection(id);
      await localDataSource.cacheCollection(updatedCollection);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> searchCollections(
      String query) async {
    try {
      // Try local first for faster search
      try {
        final localResults = await localDataSource.searchCollections(query);
        if (localResults.isNotEmpty) {
          return Right(localResults.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote search
      final remoteResults = await remoteDataSource.searchCollections(query);

      // Cache search results
      await localDataSource.cacheAllCollections(remoteResults);

      return Right(remoteResults.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getCollectionsByCategory(
      String categoryId) async {
    try {
      // Try local first
      try {
        final localCollections =
            await localDataSource.getCollectionsByCategory(categoryId);
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections =
          await remoteDataSource.getCollectionsByCategory(categoryId);

      // Cache results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getCollectionsByTag(
      String tagId) async {
    try {
      // Try local first
      try {
        final localCollections =
            await localDataSource.getCollectionsByTag(tagId);
        if (localCollections.isNotEmpty) {
          return Right(
              localCollections.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // Continue to remote if local fails
      }

      // Fallback to remote
      final remoteCollections =
          await remoteDataSource.getCollectionsByTag(tagId);

      // Cache results
      await localDataSource.cacheAllCollections(remoteCollections);

      return Right(remoteCollections.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> syncFromRemote() async {
    try {
      // Get all collections from remote
      final remoteCollections = await remoteDataSource.getAllCollections();

      // Clear local cache and replace with remote data
      await localDataSource.clearAllCollections();
      await localDataSource.cacheAllCollections(remoteCollections);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> syncToRemote() async {
    try {
      // Get all local collections that need syncing
      final localCollections = await localDataSource.getUnsyncedCollections();

      // Sync each collection to remote
      for (final collection in localCollections) {
        await remoteDataSource.updateCollection(collection);
        await localDataSource.markAsSynced(collection.id);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }
}
