// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlRepoImpl {
  UrlRepoImpl({
    required RemoteDataSourcesImpl remoteDataSourceImpl,
  }) : _remoteDataSourcesImpl = remoteDataSourceImpl;

  final RemoteDataSourcesImpl _remoteDataSourcesImpl;

  Future<void> fetchUrlData({
    required String urlDataId,
  }) async {
    // [TODO] : Fetch urlData
  }

  Future<Either<Failure, (UrlModel, CollectionModel)>> addUrlData({
    required CollectionModel collection,
    required UrlModel urlData,
    required String userId,
  }) async {
    // [TODO] : Add urlData in db
    try {
      final urlDataJson = urlData.toJson();
      urlDataJson['favicon'] = null;
      urlDataJson['banner_image'] = null;

      final optimisedUrlData = UrlModel.fromJson(urlDataJson);

      final addedUrlData = await _remoteDataSourcesImpl.addUrl(
        optimisedUrlData,
        userId: userId,
      );

      final urlList = collection.urls..insert(0, addedUrlData.id);
      final updatedCollectionWithUrls = collection.copyWith(urls: urlList);

      // updating collection
      final serverUpdatedCollection =
          await _remoteDataSourcesImpl.updateCollection(
        collection: updatedCollectionWithUrls,
        userId: userId,
      );

      return Right((addedUrlData, serverUpdatedCollection));
    } on ServerException catch (e) {
      Logger.printLog('addUrlrepo : $e');
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
    // [TODO] : Add urlData in db

    try {
      var urlMetaData = urlData.metaData;

      if (urlMetaData != null) {
        final metaDataJson = urlMetaData.toJson();
        metaDataJson['banner_image'] = null;
        metaDataJson['favicon'] = null;
        urlMetaData = UrlMetaData.fromJson(metaDataJson);
      }

      final imgRemUrlModel = urlData.copyWith(metaData: urlMetaData);

      Logger.printLog(
        StringUtils.getJsonFormat(
          imgRemUrlModel.toJson().toString(),
        ),
      );

      await _remoteDataSourcesImpl.updateUrl(
        urlModel: imgRemUrlModel,
        userId: userId,
      );

      return Right(imgRemUrlModel);
    } on ServerException catch (e) {
      Logger.printLog('updateUrlrepo : ${e.message}');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, (UrlModel, CollectionModel?)>> deleteUrlData({
    required CollectionModel? collection,
    required UrlModel urlData,
    required String userId,

  }) async {
    // [TODO] : delete urlData in db
    // then we need to update the collections also
    try {
      final deletedUrlData = await _remoteDataSourcesImpl.deleteUrl(
        urlData,
        userId: userId,
      );

      if (collection == null) {
        return Right((deletedUrlData, null));
      }
      final urlList = collection.urls
        ..removeWhere(
          (url) => url == urlData.id,
        );

      final updatedCollectionWithUrls = collection.copyWith(urls: urlList);

      // updating collection
      final serverUpdatedCollection =
          await _remoteDataSourcesImpl.updateCollection(
        collection: updatedCollectionWithUrls,
        userId: userId,
      );

      return Right((deletedUrlData, serverUpdatedCollection));
    } on ServerException catch (e) {
      Logger.printLog('deleteUrlData : $e');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }
}
