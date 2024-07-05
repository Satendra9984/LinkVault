import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

class CollectionsRepoImpl {
  CollectionsRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
  }) : _remoteDataSourcesImpl = remoteDataSourceImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;

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

        final res = await _remoteDataSourcesImpl.addCollection(
          collection: rootCollection,
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

  Future<Either<Failure, CollectionModel>> fetchSubCollection({
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

  Future<Either<Failure, CollectionModel>> addSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : Add subcollection in db

    try {
      final collection = await _remoteDataSourcesImpl.addCollection(
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

  Future<void> deleteSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : delete subcollection in db
  }

  Future<void> updateSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : update subcollection in db
  }
}
