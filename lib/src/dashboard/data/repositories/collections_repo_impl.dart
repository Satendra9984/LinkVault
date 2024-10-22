// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/dashboard/data/data_sources/collection_local_data_sources.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/data_sources/url_local_data_sources.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

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

  Future<Either<Failure, CollectionModel>> fetchRootCollection({
    required String collectionId,
    required String userId,
    String? collectionName,
  }) async {
    // Fetch Subcollection
    try {
      final localCollection =
          await _collectionLocalDataSourcesImpl.fetchCollection(collectionId);

      // // Logger.printLog('fetchRootCollection : $collectionId');

      final collection = localCollection ??
          await _remoteDataSourcesImpl.fetchCollection(
            collectionId: collectionId,
            userId: userId,
          );

      if (localCollection == null && collection != null) {
        await _collectionLocalDataSourcesImpl.addCollection(collection);
      }

      if (collection == null) {
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
        final res = await _remoteDataSourcesImpl.updateCollection(
          collection: withId,
          userId: userId,
        );
        await _collectionLocalDataSourcesImpl.updateCollection(res);
        return Right(res);
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

  Future<Either<Failure, CollectionModel>> fetchSubCollection({
    required String collectionId,
    required String userId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final localCollection =
          await _collectionLocalDataSourcesImpl.fetchCollection(collectionId);

      final collection = localCollection ??
          await _remoteDataSourcesImpl.fetchCollection(
            collectionId: collectionId,
            userId: userId,
          );

      if (localCollection == null && collection != null) {
        await _collectionLocalDataSourcesImpl.addCollection(collection);
      }

      if (collection == null) {
        return Left(
          ServerFailure(
            message: 'Something Went Wrong. Collection Not Found',
            statusCode: 400,
          ),
        );
      }

      // Now fetch subcollections

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

  Future<Either<Failure, (CollectionModel, CollectionModel?)>> addCollection({
    required CollectionModel subCollection,
    required String userId, // Optional as root collection does not have parent
    CollectionModel? parentCollection,
  }) async {
    // [TODO] : Add subcollection in db

    try {
      final collection = await _remoteDataSourcesImpl.addCollection(
        collection: subCollection,
        userId: userId,
      );

      await _collectionLocalDataSourcesImpl.addCollection(collection);
      if (parentCollection != null) {
        final updatedParentCollection = parentCollection.copyWith(
          subcollections: [
            collection.id,
            ...parentCollection.subcollections,
          ],
        );
        await _remoteDataSourcesImpl.updateCollection(
          collection: updatedParentCollection,
          userId: userId,
        );
        await _collectionLocalDataSourcesImpl
            .updateCollection(updatedParentCollection);
        return Right((collection, updatedParentCollection));
      }

      return Right((collection, null));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, (CollectionModel, CollectionModel)>> deleteCollection({
    required String collectionId,
    required String parentCollectionId,
    required String userId,
  }) async {
    try {
      final collection = await _remoteDataSourcesImpl.fetchCollection(
        collectionId: collectionId,
        userId: userId,
      );

      final parentCollection = await _remoteDataSourcesImpl.fetchCollection(
        collectionId: parentCollectionId,
        userId: userId,
      );
      if (collection == null || parentCollection == null) {
        return Left(
          ServerFailure(
            message: 'Could Not Deleted. Check internet and try again.',
            statusCode: 400,
          ),
        );
      }

      // deleting subcollections
      for (final subCollId in collection.subcollections) {
        await deleteCollection(
          collectionId: subCollId,
          parentCollectionId: collectionId,
          userId: userId,
        );
      }

      // deleting urls
      for (final urlIds in collection.urls) {
        await _remoteDataSourcesImpl.deleteUrl(
          urlIds,
          userId: userId,
        );
      }

      await _remoteDataSourcesImpl.deleteCollectionSingle(
        collectionId: collectionId,
        userId: userId,
      );
      await _collectionLocalDataSourcesImpl.deleteCollection(collectionId);
      final subCollList = parentCollection.subcollections
        ..removeWhere(
          (subCollId) => subCollId == collection.id,
        );

      final updatedParentColl = parentCollection.copyWith(
        subcollections: subCollList,
      );
      // await _collectionLocalDataSourcesImpl.deleteCollection(collection.id);
      return Right((collection, updatedParentColl));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Could Not Deleted. Check internet and try again.',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, CollectionModel>> updateSubCollection({
    required CollectionModel subCollection,
    required String userId,
    bool isOfflineOnly = false,
  }) async {
    // update subcollection in db
    try {
      var collection = subCollection;
      if (isOfflineOnly == false) {
        collection = await _remoteDataSourcesImpl.updateCollection(
          collection: subCollection,
          userId: userId,
        );
      }

      await _collectionLocalDataSourcesImpl.updateCollection(subCollection);

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

  Future<Either<Failure, UrlModel>> fetchUrl({
    required String urlId,
    required String userId,
  }) async {
    // [TODO] : Fetch Subcollection
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

      // Now fetch subcollections

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
}
