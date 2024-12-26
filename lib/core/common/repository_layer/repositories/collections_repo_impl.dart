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
    required CollectionLocalDataSourcesImpl collectionLocalDataSourcesImpl,
  })  : _remoteDataSourcesImpl = remoteDataSourceImpl,
        _collectionLocalDataSourcesImpl = collectionLocalDataSourcesImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;
  final CollectionLocalDataSourcesImpl _collectionLocalDataSourcesImpl;

  Future<Either<Failure, List<CollectionModel>>>
      fetchSubCollectionsListByFilter({
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

      final remoteCollection = localCollection?.toCollectionModel() ??
          await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
            collectionId: collectionId,
            userId: userId,
          );

      // Script for database updation to new schema
      if (remoteCollection != null &&
          (remoteCollection.subcollectionCount == null ||
              remoteCollection.urlCount == null)) {
        int? subCollectionCount;
        int? collectionUrlsCount;

        // Get the counts of subcollection and urls
        await Future.wait(
          [
            Future(
              () async => subCollectionCount =
                  await _remoteDataSourcesImpl.getSubCollectionCount(
                userId: userId,
                collectionId: collectionId,
              ),
            ),
            Future(
              () async => collectionUrlsCount =
                  await _remoteDataSourcesImpl.getCollectionUrlsCount(
                userId: userId,
                collectionId: collectionId,
              ),
            ),
          ],
        );

        final updatedCollectionWithCount = remoteCollection.copyWith(
          subcollectionCount: subCollectionCount,
          urlCount: collectionUrlsCount,
        );
        // Update both remote database and local database with
        // updated collectionwithcount
        await Future.wait(
          [
            _remoteDataSourcesImpl.updateCollectionInRemoteDB(
              collection: updatedCollectionWithCount,
              userId: userId,
            ),
            _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
              updatedCollectionWithCount,
            ),
          ],
        );

        return Right(updatedCollectionWithCount);
      }

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
        await _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(res);
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

      if (collection == null) {
        return Left(
          ServerFailure(
            message: 'Something Went Wrong. Collection Not Found',
            statusCode: 400,
          ),
        );
      }

      if (collection.subcollectionCount == null ||
          collection.urlCount == null) {
        int? subCollectionCount;
        int? collectionUrlsCount;

        await Future.wait(
          [
            Future(
              () async => subCollectionCount =
                  await _remoteDataSourcesImpl.getSubCollectionCount(
                userId: userId,
                collectionId: collectionId,
              ),
            ),
            Future(
              () async => collectionUrlsCount =
                  await _remoteDataSourcesImpl.getCollectionUrlsCount(
                userId: userId,
                collectionId: collectionId,
              ),
            ),
          ],
        );

        final updatedCollectionWithCount = collection.copyWith(
          subcollectionCount: subCollectionCount,
          urlCount: collectionUrlsCount,
        );

        await Future.wait(
          [
            _remoteDataSourcesImpl.updateCollectionInRemoteDB(
              collection: updatedCollectionWithCount,
              userId: userId,
            ),
            _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
              updatedCollectionWithCount,
            ),
          ],
        );

        return Right(updatedCollectionWithCount);
      }

      if (localCollection == null) {
        await _collectionLocalDataSourcesImpl
            .addCollectionInLocalDB(collection);
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

  Future<Either<Failure, (CollectionModel, CollectionModel? parentCollection)>>
      addCollection({
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

      // UPDATE PARENT-COLLECTION's SUB-COLLECTION COUNT
      final parentCollection =
          await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
        collectionId: collection.parentCollection,
        userId: userId,
      );

      if (parentCollection == null ||
          parentCollection.subcollectionCount == null) {
        return Right((addedCollection, parentCollection));
      }

      final updatedParentCollectionWithSubCount = parentCollection.copyWith(
        subcollectionCount: parentCollection.subcollectionCount! + 1,
      );

      await Future.wait(
        [
          _remoteDataSourcesImpl.updateCollectionInRemoteDB(
            collection: updatedParentCollectionWithSubCount,
            userId: userId,
          ),
          _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
            updatedParentCollectionWithSubCount,
          ),
        ],
      );

      return Right((addedCollection, updatedParentCollectionWithSubCount));
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

  Future<Either<Failure, (bool deleted, CollectionModel? parentCollection)>>
      deleteCollection({
    required CollectionModel collection,
    required String userId,
  }) async {
    try {
      await Future.wait(
        [
          _remoteDataSourcesImpl.deleteCollectionAndAssociatedData(
            userId: userId,
            collectionId: collection.id,
          ),
          _collectionLocalDataSourcesImpl
              .deleteCollectionAndAssociatedDataInLocalDB(
            collectionId: collection.id,
          ),
        ],
      );

      // UPDATE PARENT-COLLECTION's SUB-COLLECTION COUNT
      final parentCollection =
          await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
        collectionId: collection.parentCollection,
        userId: userId,
      );

      if (parentCollection == null ||
          parentCollection.subcollectionCount == null) {
        return Right((true, parentCollection));
      }

      final updatedParentCollectionWithSubCount = parentCollection.copyWith(
        subcollectionCount: parentCollection.subcollectionCount! - 1,
      );

      await Future.wait(
        [
          _remoteDataSourcesImpl.updateCollectionInRemoteDB(
            collection: updatedParentCollectionWithSubCount,
            userId: userId,
          ),
          _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
            updatedParentCollectionWithSubCount,
          ),
        ],
      );

      return Right((true, updatedParentCollectionWithSubCount));
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

  // FOR LOCAL ONLY IMPLEMENTATIONS
  Future<Either<Failure, bool>> deleteCollectionLocally({
    required String collectionId,
    required String parentCollectionId,
    // required String userId,
  }) async {
    try {
      await _collectionLocalDataSourcesImpl
          .deleteCollectionAndAssociatedDataInLocalDB(
        collectionId: collectionId,
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
