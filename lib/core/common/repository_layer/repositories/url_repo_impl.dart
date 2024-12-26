// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/collection_local_data_source.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/url_local_data_sources.dart';
import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/collection_remote_data_source.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_filters_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_meta_data.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';

class UrlRepoImpl {
  UrlRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
    required CollectionLocalDataSourcesImpl collectionLocalDataSourcesImpl,
  })  : _remoteDataSourcesImpl = remoteDataSourceImpl,
        _collectionLocalDataSourcesImpl = collectionLocalDataSourcesImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;
  final CollectionLocalDataSourcesImpl _collectionLocalDataSourcesImpl;

  Future<Either<Failure, List<UrlModel>>> fetchUrlsListByFilter({
    required UrlModelFilters filter,
    required String userId,
  }) async {
    try {
      final localDBUrls = await _collectionLocalDataSourcesImpl
          .fetchUrlsFromLocalDB(filter: filter);

      final remoteDBUrls = localDBUrls ??
          await _remoteDataSourcesImpl.fetchUrlsFromRemoteDB(
            filter: filter,
            userId: userId,
          );

      if (localDBUrls == null) {
        for (final urlModel in remoteDBUrls) {
          await _collectionLocalDataSourcesImpl.addUrlInLocalDB(urlModel);
        }
      }

      // Now fetch subcollections
      return Right(remoteDBUrls);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, UrlModel>> fetchUrlData({
    required String urlId,
    required String userId,
  }) async {
    try {
      // Logger.printLog('[URL] : fetching $urlId');
      final localUrl =
          await _collectionLocalDataSourcesImpl.fetchUrlFromLocalDB(urlId);

      final url = localUrl ??
          await _remoteDataSourcesImpl.fetchUrlFromRemoteDB(
            urlId,
            userId: userId,
          );

      if (localUrl == null) {
        await _collectionLocalDataSourcesImpl.addUrlInLocalDB(url);
      }

      // Now fetch subcollections
      return Right(url);
    } catch (e) {
      Logger.printLog('[URL] : fetcherror $e');

      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  // COMPLETED FOR THE NEW ARCHITECTURE
  Future<
      Either<
          Failure,
          (
            UrlModel addedUrlModel,
            CollectionModel? updatedParentCollection,
          )>> addUrlData({
    required CollectionModel collection,
    required UrlModel urlModel,
    required String userId,
  }) async {
    // Add urlData in db
    try {
      final addedUrlModelInRemoteDB = await _remoteDataSourcesImpl
          .addUrlInRemoteDB(
        userId: userId,
        urlModel.copyWith(
          metaData: urlModel.metaData?.removedMetaDataForRemoteDB(),
          htmlContent: '',
        ),
      )
          .then(
        (addedmodel) async {
          // But storing addedurldata in local for firestore id
          await _collectionLocalDataSourcesImpl.addUrlInLocalDB(
            addedmodel.copyWith(
              metaData: urlModel.metaData,
            ),
          );
        },
      );

      // UPDATE PARENT-COLLECTION's SUB-COLLECTION COUNT
      final parentCollection =
          await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
        collectionId: collection.parentCollection,
        userId: userId,
      );

      if (parentCollection == null || parentCollection.urlCount == null) {
        return Right((addedUrlModelInRemoteDB, parentCollection));
      }

      final updatedParentCollectionWithUrlCount = parentCollection.copyWith(
        subcollectionCount: parentCollection.urlCount! + 1,
      );

      await Future.wait(
        [
          _remoteDataSourcesImpl.updateCollectionInRemoteDB(
            collection: updatedParentCollectionWithUrlCount,
            userId: userId,
          ),
          _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
            updatedParentCollectionWithUrlCount,
          ),
        ],
      );

      return Right(
        (addedUrlModelInRemoteDB, updatedParentCollectionWithUrlCount),
      );
    } on ServerException {
      // Logger.printLog('addUrlrepo : $e');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  // COMPLETED FOR THE NEW ARCHITECTURE
  Future<Either<Failure, bool>> updateUrl({
    required UrlModel urlModel,
    required String userId,
  }) async {
    // Add urlData in db
    try {
      await Future.wait(
        [
          _remoteDataSourcesImpl.updateUrlInRemoteDB(
            userId: userId,
            urlModel: urlModel.copyWith(
              metaData: urlModel.metaData?.removedMetaDataForRemoteDB(),
              htmlContent: '',
            ),
          ),
          _collectionLocalDataSourcesImpl.updateUrlInLocalDB(
            urlModel,
          ),
        ],
      );

      return const Right(true);
    } on ServerException {
      // Logger.printLog('updateUrlrepo : ${e.message}');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  // COMPLETED FOR THE NEW ARCHITECTURE
  Future<
      Either<
          Failure,
          (
            bool deleted,
            CollectionModel? updatedParentCollectionModel,
          )>> deleteUrlData({
    required CollectionModel collection,
    required UrlModel urlData,
    required String userId,
  }) async {
    // then we need to update the collections also
    try {
      CollectionModel? parentCollection;

      // Deleting the Urls in the Databases
      // Same time fetching the parentcollection
      await Future.wait(
        [
          _remoteDataSourcesImpl.deleteUrlInRemoteDB(
            urlId: urlData.firestoreId,
            userId: userId,
          ),
          _collectionLocalDataSourcesImpl.deleteUrlInLocalDB(
            urlData.firestoreId,
          ),
          Future(
            () async => parentCollection =
                await _remoteDataSourcesImpl.fetchCollectionFromRemoteDB(
              collectionId: collection.parentCollection,
              userId: userId,
            ),
          ),
        ],
      );

      // UPDATE PARENT-COLLECTION's SUB-COLLECTION COUNT

      if (parentCollection == null || parentCollection!.urlCount == null) {
        return Right((true, parentCollection));
      }

      final updatedParentCollectionWithUrlCount = parentCollection!.copyWith(
        subcollectionCount: parentCollection!.urlCount! - 1,
      );

      await Future.wait(
        [
          _remoteDataSourcesImpl.updateCollectionInRemoteDB(
            collection: updatedParentCollectionWithUrlCount,
            userId: userId,
          ),
          _collectionLocalDataSourcesImpl.updateCollectionInLocalDB(
            updatedParentCollectionWithUrlCount,
          ),
        ],
      );

      return Right(
        (true, updatedParentCollectionWithUrlCount),
      );
    } on ServerException {
      // Logger.printLog('deleteUrlData : $e');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, bool>> updateUrlLocally({
    required UrlModel urlData,
  }) async {
    // Add urlData in db
    try {
      await _collectionLocalDataSourcesImpl.updateUrlInLocalDB(urlData);

      return const Right(true);
    } on ServerException {
      // Logger.printLog('updateUrlrepo : ${e.message}');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  /// LOCAL DB IMPLEMENTATIONS MAINLY FOR SYNCING
  Future<Either<Failure, bool>> deleteUrlDatalocally({
    required String urlModelId,
  }) async {
    // then we need to update the collections also
    try {
      await _collectionLocalDataSourcesImpl.deleteUrlInLocalDB(urlModelId);

      return const Right(true);
    } on ServerException {
      // Logger.printLog('deleteUrlData : $e');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }
}
