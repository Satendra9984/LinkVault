import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class CollectionsRepoImpl {
  CollectionsRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
  }) : _remoteDataSourcesImpl = remoteDataSourceImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;

  Future<
      Either<
          Failure,
          (
            CollectionModel,
            Map<String, CollectionModel>,
            List<UrlModel>,
          )>> fetchRootCollection({
    required String collectionId,
    required String userId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final collection = await _remoteDataSourcesImpl.fetchCollection(
        collectionId: collectionId,
      );

      if (collection == null) {
        final todaydate = DateTime.now();
        final status = {'status': 'active'};

        final rootCollection = CollectionModel.isEmpty(
          userId: userId,
          name: rootCollectionName,
          parentCollection: userId,
          status: status,
          createdAt: todaydate,
          updatedAt: todaydate,
        );

        final withId = rootCollection.copyWith(id: collectionId);
        final res = await _remoteDataSourcesImpl.updateCollection(
          collection: withId,
        );

        return Right((res, {}, []));
      }
      // Now fetch subcollections
      final subCollMap = <String, CollectionModel>{};
      final urlList = <UrlModel>[];

      for (final subcId in collection.subcollections) {
        final subcollection = await _remoteDataSourcesImpl.fetchCollection(
          collectionId: subcId,
        );
        if (subcollection == null) {
          return Left(
            ServerFailure(
              message: 'Something Went Wrong. Collection Not Found',
              statusCode: 400,
            ),
          );
        }
        subCollMap[subcollection.id] = subcollection;
      }

      // NOW WILL FETCH URLS FOR THIS COLLECTION

      for (final urlId in collection.urls) {}

      return Right(
        (
          collection,
          subCollMap,
          urlList,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<
      Either<
          Failure,
          (
            CollectionModel,
            Map<String, CollectionModel>,
            List<UrlModel>,
          )>> fetchSubCollectionAsWhole({
    required String collectionId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final collection = await _remoteDataSourcesImpl.fetchCollection(
        collectionId: collectionId,
      );

      if (collection == null) {
        return Left(
          ServerFailure(
            message: 'Something Went Wrong. Collection Not Found',
            statusCode: 400,
          ),
        );
      }

      // Now fetch subcollections
      final subCollMap = <String, CollectionModel>{};
      for (final subcId in collection.subcollections) {
        final subcollection = await _remoteDataSourcesImpl.fetchCollection(
          collectionId: subcId,
        );
        if (subcollection == null) {
          return Left(
            ServerFailure(
              message: 'Something Went Wrong. Collection Not Found',
              statusCode: 400,
            ),
          );
        }
        subCollMap[subcollection.id] = subcollection;
      }

      // NOW WILL FETCH URLS FOR THIS COLLECTION
      final List<UrlModel> urlList = [];

      for (final urlId in collection.urls) {}

      return Right(
        (
          collection,
          subCollMap,
          urlList,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, CollectionModel>> fetchSubCollectionOnly({
    required String collectionId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final collection = await _remoteDataSourcesImpl.fetchCollection(
        collectionId: collectionId,
      );

      if (collection == null) {
        return Left(
          ServerFailure(
            message: 'Something Went Wrong. Collection Not Found',
            statusCode: 400,
          ),
        );
      }

      // Now fetch subcollections and Urls also

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

  Future<
          Either<Failure,
              (CollectionModel added, CollectionModel? updatedParent)>>
      addSubCollection({
    required CollectionModel subCollection,
    // Optional as root collection does not have parent
    CollectionModel? parentCollection,
  }) async {
    // [TODO] : Add subcollection in db

    try {
      final collection = await _remoteDataSourcesImpl.addCollection(
        collection: subCollection,
      );

      if (parentCollection != null) {
        final updatedParentCollection = parentCollection.copyWith(
          subcollections: [
            ...parentCollection.subcollections,
            collection.id,
          ],
        );
        await _remoteDataSourcesImpl.updateCollection(
          collection: updatedParentCollection,
        );
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

  Future<void> deleteSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : delete subcollection in db
  }

  Future<Either<Failure, CollectionModel>> updateSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : update subcollection in db

    try {
      final collection = await _remoteDataSourcesImpl.updateCollection(
        collection: subCollection,
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
}
