import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';

class CollectionsRepoImpl {
  CollectionsRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
    UrlRepoImpl? urlRepoImpl,
  }) : _remoteDataSourcesImpl = remoteDataSourceImpl;
  // _urlRepoImpl = urlRepoImpl ??
  //     UrlRepoImpl(remoteDataSourceImpl: remoteDataSourceImpl);

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;
  // final UrlRepoImpl _urlRepoImpl;

  Future<Either<Failure, CollectionModel>> fetchRootCollection({
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

  Future<Either<Failure, CollectionModel>> fetchSubCollectionAsWhole({
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

  Future<Either<Failure, (CollectionModel, CollectionModel?)>> addCollection({
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

  Future<Either<Failure, (CollectionModel, CollectionModel)>> deleteCollection({
    required CollectionModel collection,
    required CollectionModel parentCollection,
  }) async {
    // [TODO] : delete subcollection in db

    try {
      await _remoteDataSourcesImpl.deleteCollection(
        collectionId: collection.id,
      );

      final subCollList = parentCollection.subcollections
        ..removeWhere(
          (subCollId) => subCollId == collection.id,
        );

      final updatedParentColl = parentCollection.copyWith(
        subcollections: subCollList,
      );

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


  Future<Either<Failure, UrlModel>> fetchUrl({
    required String urlId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final collection = await _remoteDataSourcesImpl.fetchUrl(
        urlId
      );

      // if (collection == null) {
      //   return Left(
      //     ServerFailure(
      //       message: 'Something Went Wrong. Collection Not Found',
      //       statusCode: 400,
      //     ),
      //   );
      // }

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

}
