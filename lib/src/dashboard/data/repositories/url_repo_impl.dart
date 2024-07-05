// ignore_for_file: public_member_api_docs

import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
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

  Future<void> addUrlData({
    required UrlModel urlData,
  }) async {
    // [TODO] : Add urlData in db
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
