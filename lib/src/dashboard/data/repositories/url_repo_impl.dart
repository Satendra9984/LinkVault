// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';
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
  }) async {
    // [TODO] : Add urlData in db

    try {
    final addedUrlData = await _remoteDataSourcesImpl.addUrl(urlData);

    final urlList = collection.urls..add(addedUrlData.id);
    final updatedCollectionWithUrls = collection.copyWith(urls: urlList);

    // updating collection
    final serverUpdatedCollection =
        await _remoteDataSourcesImpl.updateCollection(
      collection: updatedCollectionWithUrls,
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

  Future<void> deleteUrlData({
    required UrlModel urlData,
  }) async {
    // [TODO] : delete urlData in db
    // then we need to update the collections also
  }

  Future<void> updateUrlData({
    required UrlModel urlData,
  }) async {
    // [TODO] : update urlData in db
  }
}
