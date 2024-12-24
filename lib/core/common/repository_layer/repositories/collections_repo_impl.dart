// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/collection_local_data_source.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/url_local_data_sources.dart';
import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/collection_remote_data_source.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/collection_model_isar.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';

class CollectionsRepoImpl {
  CollectionsRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
    required UrlLocalDataSourcesImpl urlLocalDataSourcesImpl,
    required CollectionLocalDataSourcesImpl collectionLocalDataSourcesImpl,
  })  : _remoteDataSourcesImpl = remoteDataSourceImpl,
        _urlLocalDataSourcesImpl = urlLocalDataSourcesImpl,
        _collectionLocalDataSourcesImpl = collectionLocalDataSourcesImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;
  final UrlLocalDataSourcesImpl _urlLocalDataSourcesImpl;
  final CollectionLocalDataSourcesImpl _collectionLocalDataSourcesImpl;

  Future<Either<Failure, List<CollectionModel>>> fetchSubCollectionsByFilter({
    required CollectionFilter filter,
    required String userId,
  }) async {
    try {
      final localCollection = await _collectionLocalDataSourcesImpl
          .fetchCollectionWithFilters(filter);

      final collections = localCollection ??
          await _remoteDataSourcesImpl.fetchCollectionsFromRemoteDB(
            filter: filter,
            userId: userId,
          );

      if (localCollection == null && collections != null) {
        for (final coll in collections) {
          await _collectionLocalDataSourcesImpl.addCollectionInLocalDB(coll);
        }
      }

      if (collections == null) {
        return Left(
          ServerFailure(
            message: 'Something Went Wrong. Collection Not Found',
            statusCode: 400,
          ),
        );
      }

      // Now fetch subcollections
      return Right(collections);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, CollectionModel>> fetchRootCollection({
    required String collectionId,
    required String userId,
    String? collectionName,
  }) async {
    // Fetch Subcollection
    try {
      final localCollection = await _collectionLocalDataSourcesImpl
          .fetchCollectionModelIsar(collectionId);

      // Logger.printLog('fetchRootCollection : $collectionId');

      final remoteCollection = localCollection?.toCollectionModel() ??
          await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
            collectionId: collectionId,
            userId: userId,
          );

      if (localCollection == null && remoteCollection != null) {
        await _collectionLocalDataSourcesImpl
            .addCollectionInLocalDB(remoteCollection);
      }

      if (remoteCollection == null) {
        final todaydate = DateTime.now().toUtc();
        final status = {'status': 'active'};

        final rootCollection = CollectionModel.isEmpty(
          userId: userId,
          name: collectionName ?? rootCollectionName,
          parentCollection: userId,
          status: status,
          createdAt: todaydate,
          updatedAt: todaydate,
        );

        final withId = rootCollection.copyWith(id: collectionId);

        final res = await _remoteDataSourcesImpl.updateCollectionInRemoteDB(
          collection: withId,
          userId: userId,
        );
        await _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
          CollectionModelIsar.fromCollectionModel(res),
        );
        return Right(res);
      }

      return Right(remoteCollection);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, CollectionModel>> fetchSubCollection({
    required String collectionId,
    required String userId,
  }) async {
    try {
      final localCollection = await _collectionLocalDataSourcesImpl
          .fetchCollectionModelIsar(collectionId);

      final collection = localCollection?.toCollectionModel() ??
          await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
            collectionId: collectionId,
            userId: userId,
          );

      if (localCollection == null && collection != null) {
        await _collectionLocalDataSourcesImpl
            .addCollectionInLocalDB(collection);
      }

      if (collection == null) {
        return Left(
          ServerFailure(
            message: 'Something Went Wrong. Collection Not Found',
            statusCode: 400,
          ),
        );
      }

      return Right(collection);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, CollectionModel>> addCollection({
    required CollectionModel collection,
    required String userId,
  }) async {
    try {
      final addedCollection =
          await _remoteDataSourcesImpl.addCollectionInRemoteDB(
        collection: collection,
        userId: userId,
      );

      await _collectionLocalDataSourcesImpl
          .addCollectionInLocalDB(addedCollection);

      return Right(addedCollection);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, CollectionModel>> updateSubCollection({
    required CollectionModel collection,
    required String userId,
  }) async {
    // update subcollection in db
    try {
      await Future.wait(
        [
          _remoteDataSourcesImpl.updateCollectionInRemoteDB(
            collection: collection,
            userId: userId,
          ),
          _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(collection),
        ],
      );

      return Right(collection);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, Unit>> deleteCollection({
    required String collectionId,
    required String userId,
  }) async {
    try {
      await Future.wait(
        [
          _remoteDataSourcesImpl.deleteCollectionAndAssociatedData(
            userId: userId,
            collectionId: collectionId,
          ),
          _collectionLocalDataSourcesImpl
              .deleteCollectionAndAssociatedDataInLocalDB(
            collectionId: collectionId,
          ),
        ],
      );

      return const Right(unit);
    } catch (e) {
      Logger.printLog('[URL] : ${e}');
      return Left(
        ServerFailure(
          message: 'Could Not Deleted. Check internet and try again.',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, UrlModel>> fetchUrl({
    required String urlId,
    required String userId,
  }) async {
    try {
      final localUrl = await _urlLocalDataSourcesImpl.fetchUrl(urlId);

      final url = localUrl ??
          await _remoteDataSourcesImpl.fetchUrl(
            urlId,
            userId: userId,
          );

      if (localUrl == null) {
        await _urlLocalDataSourcesImpl.addUrl(url);
      }

      return Right(url);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  // FOR LOCAL ONLY IMPLEMENTATIONS
  Future<Either<Failure, bool>> deleteCollectionLocally({
    required String collectionId,
    required String parentCollectionId,
    // required String userId,
  }) async {
    try {
      final collection =
          await _collectionLocalDataSourcesImpl.fetchCollectionModelIsar(
        collectionId,
      );

      if (collection == null) {
        return Left(
          ServerFailure(
            message: 'Could Not Deleted. Check internet and try again.',
            statusCode: 400,
          ),
        );
      }

      // deleting subcollections
      for (final subCollId in collection.subcollections) {
        await deleteCollectionLocally(
          collectionId: subCollId,
          parentCollectionId: collectionId,
        );
      }

      await Future.wait(
        [
          Future(
            () async {
              // NEED TO DELETE URLS AS IT WILL BE REFETCHED AND UPDATED FROM ISAR
              for (final urlId in collection.urls) {
                await _urlLocalDataSourcesImpl.deleteUrl(urlId);
              }
            },
          ),
          _collectionLocalDataSourcesImpl
              .deleteCollectionInLocalDB(collectionId),
        ],
      );

      return const Right(true);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Could Not Deleted. Check internet and try again.',
          statusCode: 400,
        ),
      );
    }
  }
}
