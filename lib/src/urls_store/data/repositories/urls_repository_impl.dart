// lib/features/urls/data/repositories/urls_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/urls_store/data/datasources/urls_local_datasource.dart';
import 'package:link_vault/src/urls_store/data/datasources/urls_remote_datasource.dart';
import 'package:link_vault/src/urls_store/data/models/url_model.dart';
import 'package:link_vault/src/urls_store/domain/entities/url_entity.dart';
import 'package:link_vault/src/urls_store/domain/repository/url_repository.dart';

class UrlsRepositoryImpl implements UrlsRepository {
  const UrlsRepositoryImpl({
    required UrlsRemoteDataSource remoteDataSource,
    required UrlsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final UrlsRemoteDataSource _remoteDataSource;
  final UrlsLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, UrlEntity>> createUrl(UrlEntity url) async {
    try {
      // Convert entity to model for data layer operations
      final urlModel = UrlModel.fromEntity(url);

      // Pessimistic approach: Create remotely first
      final remoteResult = await _remoteDataSource.createUrl(urlModel);

      // Cache locally after successful remote creation
      await _localDataSource.createUrl(remoteResult);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> getUrl(String id) async {
    try {
      // Try local first for reads (offline-first approach)
      try {
        final localResult = await _localDataSource.getUrl(id);
        return Right(localResult.toEntity());
      } on CacheException {
        // If not found locally, try remote
        final remoteResult = await _remoteDataSource.getUrl(id);

        // Cache the result locally
        await _localDataSource.createUrl(remoteResult);

        return Right(remoteResult.toEntity());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getUrlsByCollection(
    String collectionId, {
    bool includeArchived = false,
  }) async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getUrlsByCollection(
          collectionId,
          includeArchived: includeArchived,
        );
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getUrlsByCollection(
          collectionId,
          includeArchived: includeArchived,
        );

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> updateUrl(UrlEntity url) async {
    try {
      final urlModel = UrlModel.fromEntity(url);

      // Pessimistic approach: Update remotely first
      final remoteResult = await _remoteDataSource.updateUrl(urlModel);

      // Update locally after successful remote update
      await _localDataSource.updateUrl(remoteResult);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUrl(String id) async {
    try {
      // Pessimistic approach: Delete remotely first
      await _remoteDataSource.deleteUrl(id);

      // Delete locally after successful remote deletion
      await _localDataSource.deleteUrl(id);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> createUrls(
      List<UrlEntity> urls) async {
    try {
      final urlModels = urls.map((url) => UrlModel.fromEntity(url)).toList();

      // Pessimistic approach: Create remotely first
      final remoteResults = await _remoteDataSource.createUrls(urlModels);

      // Cache locally after successful remote creation
      for (final urlModel in remoteResults) {
        await _localDataSource.createUrl(urlModel);
      }

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUrls(List<String> ids) async {
    try {
      // Pessimistic approach: Delete remotely first
      await _remoteDataSource.deleteUrls(ids);

      // Delete locally after successful remote deletion
      await _localDataSource.deleteUrls(ids);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> moveUrls(
    List<String> urlIds,
    String targetCollectionId,
  ) async {
    try {
      // Pessimistic approach: Move remotely first
      final remoteResults = await _remoteDataSource.moveUrls(
        urlIds,
        targetCollectionId,
      );

      // Update locally after successful remote move
      for (final urlModel in remoteResults) {
        await _localDataSource.updateUrl(urlModel);
      }

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> togglePin(String id) async {
    try {
      // Get current URL state
      final getCurrentResult = await getUrl(id);
      if (getCurrentResult.isLeft()) {
        return getCurrentResult;
      }

      final currentUrl = getCurrentResult.getOrElse(() {
        throw Exception();
      });
      final updatedUrl = currentUrl.copyWith(isPinned: !currentUrl.isPinned);

      return await updateUrl(updatedUrl);
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getPinnedUrls() async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getPinnedUrls();
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getPinnedUrls();

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getPinnedUrlsByCollection(
    String collectionId,
  ) async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getPinnedUrlsByCollection(
          collectionId,
        );
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getPinnedUrlsByCollection(
          collectionId,
        );

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> toggleArchive(String id) async {
    try {
      // Get current URL state
      final getCurrentResult = await getUrl(id);
      if (getCurrentResult.isLeft()) {
        return getCurrentResult;
      }

      final currentUrl = getCurrentResult.getOrElse(() => throw Exception());
      final updatedUrl =
          currentUrl.copyWith(isArchived: !currentUrl.isArchived);

      return await updateUrl(updatedUrl);
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getArchivedUrls() async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getArchivedUrls();
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getArchivedUrls();

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> incrementClickCount(String id) async {
    try {
      // Pessimistic approach: Update remotely first
      final remoteResult = await _remoteDataSource.incrementClickCount(id);

      // Update locally after successful remote update
      await _localDataSource.updateUrl(remoteResult);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> updateLastAccessed(String id) async {
    try {
      // Pessimistic approach: Update remotely first
      final remoteResult = await _remoteDataSource.updateLastAccessed(id);

      // Update locally after successful remote update
      await _localDataSource.updateUrl(remoteResult);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getMostVisitedUrls(
      {int limit = 10}) async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getMostVisitedUrls(
          limit: limit,
        );
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getMostVisitedUrls(
          limit: limit,
        );

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> updatePosition(
      String id, int newPosition) async {
    try {
      // Get current URL state
      final getCurrentResult = await getUrl(id);
      if (getCurrentResult.isLeft()) {
        return getCurrentResult;
      }

      final currentUrl = getCurrentResult.getOrElse(() => throw Exception());
      final updatedUrl = currentUrl.copyWith(position: newPosition);

      return await updateUrl(updatedUrl);
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> reorderUrls(
    String collectionId,
    List<String> orderedIds,
  ) async {
    try {
      // Pessimistic approach: Update remotely first
      await _remoteDataSource.reorderUrls(collectionId, orderedIds);

      // Update locally after successful remote reorder
      await _localDataSource.reorderUrls(collectionId, orderedIds);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> updateMetadata(
    String id,
    Map<String, dynamic> metadata,
  ) async {
    try {
      // Get current URL state
      final getCurrentResult = await getUrl(id);
      if (getCurrentResult.isLeft()) {
        return getCurrentResult;
      }

      final currentUrl = getCurrentResult.getOrElse(() => throw Exception());
      final updatedUrl = currentUrl.copyWith(metadata: metadata);

      return await updateUrl(updatedUrl);
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, UrlEntity>> enrichUrlData(String id) async {
    try {
      // Pessimistic approach: Enrich remotely first (this likely involves web scraping)
      final remoteResult = await _remoteDataSource.enrichUrlData(id);

      // Update locally after successful remote enrichment
      await _localDataSource.updateUrl(remoteResult);

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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> searchUrls(String query) async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.searchUrls(query);
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.searchUrls(query);

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getUrlsByTag(String tagId) async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getUrlsByTag(tagId);
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getUrlsByTag(tagId);

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<UrlEntity>>> getRecentUrls(
      {int limit = 20}) async {
    try {
      // Try local first for reads
      try {
        final localResults = await _localDataSource.getRecentUrls(limit: limit);
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException {
        // If not found locally, try remote
        final remoteResults = await _remoteDataSource.getRecentUrls(
          limit: limit,
        );

        // Cache the results locally
        for (final urlModel in remoteResults) {
          await _localDataSource.createUrl(urlModel);
        }

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      }
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
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> syncFromRemote() async {
    try {
      // Fetch all URLs from remote
      final remoteUrls = await _remoteDataSource.getAllUrls();

      // Clear local cache and rebuild from remote data
      await _localDataSource.clearAll();

      // Cache all remote URLs locally
      for (final urlModel in remoteUrls) {
        await _localDataSource.createUrl(urlModel);
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
        message: 'An unexpected error occurred during sync: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> syncToRemote() async {
    try {
      // Get all local URLs that need syncing
      final localUrls = await _localDataSource.getAllUrls();

      // Push each URL to remote (this would typically involve checking timestamps
      // or sync flags to determine what needs updating)
      for (final urlModel in localUrls) {
        await _remoteDataSource.updateUrl(urlModel);
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
        message: 'An unexpected error occurred during sync: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }
}
