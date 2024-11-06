// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/collection_local_data_source.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/url_local_data_sources.dart';
import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/collection_remote_data_source.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';

class UrlRepoImpl {
  UrlRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
    required UrlLocalDataSourcesImpl urlLocalDataSourcesImpl,
    required CollectionLocalDataSourcesImpl collectionLocalDataSourcesImpl,
  })  : _remoteDataSourcesImpl = remoteDataSourceImpl,
        _urlLocalDataSourcesImpl = urlLocalDataSourcesImpl,
        _collectionLocalDataSourcesImpl = collectionLocalDataSourcesImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;
  final UrlLocalDataSourcesImpl _urlLocalDataSourcesImpl;
  final CollectionLocalDataSourcesImpl _collectionLocalDataSourcesImpl;

  Future<Either<Failure, UrlModel>> fetchUrlData({
    required String urlId,
    required String userId,
  }) async {
    // [TODO] : Fetch urlData
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

  Future<Either<Failure, (UrlModel, CollectionModel)>> addUrlData({
    required CollectionModel collection,
    required UrlModel urlData,
    required String userId,
  }) async {
    // Add urlData in db
    try {
      // Removing images bytes data for remote database storage
      final urlMetaDataJson = urlData.metaData?.toJson() ?? {};
      urlMetaDataJson['favicon'] = null;
      urlMetaDataJson['banner_image'] = null;

      final optimisedUrlData = urlData.copyWith(
        metaData: UrlMetaData.fromJson(urlMetaDataJson),
      );

      // Logger.printLog('Adding url metadata');
      // Logger.printLog(StringUtils.getJsonFormat(optimisedUrlData));

      final addedUrlData = await _remoteDataSourcesImpl.addUrl(
        optimisedUrlData,
        userId: userId,
      );

      // But storing addedurldata in local for firestore id
      await _urlLocalDataSourcesImpl.addUrl(addedUrlData);

      final urlList = {
        addedUrlData.firestoreId,
        ...collection.urls,
      }.toList();

      // collection.urls
      //   ..insert(0, addedUrlData.firestoreId)
      //   ..toSet();

      final updatedCollectionWithUrls = collection.copyWith(urls: urlList);

      // updating collection
      final serverUpdatedCollection =
          await _remoteDataSourcesImpl.updateCollection(
        collection: updatedCollectionWithUrls,
        userId: userId,
      );

      // final url with metadata for app state
      final readdedMetaDataUrlModel = addedUrlData.copyWith(
        metaData: urlData.metaData,
      );

      await _collectionLocalDataSourcesImpl
          .updateCollection(updatedCollectionWithUrls);

      return Right((readdedMetaDataUrlModel, serverUpdatedCollection));
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

  Future<Either<Failure, UrlModel>> updateUrl({
    required UrlModel urlData,
    required String userId,
  }) async {
    // Add urlData in db
    try {
      final urlMetaDataJson = urlData.metaData?.toJson() ?? {};
      urlMetaDataJson['favicon'] = null;
      urlMetaDataJson['banner_image'] = null;

      final optimisedUrlData = urlData.copyWith(
        metaData: UrlMetaData.fromJson(urlMetaDataJson),
      );

      await _remoteDataSourcesImpl.updateUrl(
        urlModel: optimisedUrlData,
        userId: userId,
      );

      // Logger.printLog('calling update url local');
      await _urlLocalDataSourcesImpl.updateUrl(optimisedUrlData);

      return Right(optimisedUrlData);
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

  Future<Either<Failure, (UrlModel, CollectionModel?)>> deleteUrlData({
    required CollectionModel collection,
    required UrlModel urlData,
    required String userId,
  }) async {
    // [TODO] : delete urlData in db
    // then we need to update the collections also
    try {
      await _remoteDataSourcesImpl.deleteUrl(
        urlData.firestoreId,
        userId: userId,
      );

      await _urlLocalDataSourcesImpl.deleteUrl(urlData.firestoreId);
      final urlList = collection.urls
        ..removeWhere(
          (url) => url == urlData.firestoreId,
        );

      final updatedCollectionWithUrls = collection.copyWith(urls: urlList);

      // updating collection
      final serverUpdatedCollection =
          await _remoteDataSourcesImpl.updateCollection(
        collection: updatedCollectionWithUrls,
        userId: userId,
      );

      await _collectionLocalDataSourcesImpl
          .updateCollection(updatedCollectionWithUrls);

      return Right((urlData, serverUpdatedCollection));
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

  /// LOCAL DB IMPLEMENTATIONS MAINLY FOR SYNCING

  Future<Either<Failure, bool>> deleteUrlDatalocally({
    required String urlModelId,
  }) async {
    // [TODO] : delete urlData in db
    // then we need to update the collections also
    try {
      await _urlLocalDataSourcesImpl.deleteUrl(urlModelId);

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
