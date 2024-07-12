import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class RemoteDataSourcesImpl {
  RemoteDataSourcesImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// It will use `userId` to fetch root collection currently
  Future<CollectionModel?> fetchCollection({
    required String collectionId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final response = await _firestore
          .collection(folderCollections)
          .doc(collectionId)
          .get();

      final data = response.data();

      if (data == null) {
        // That mean user is using it first time may be
        return null;
      }

      // user is not using first time
      data['id'] = response.id;

      final collectionModel = CollectionModel.fromJson(data);

      return collectionModel;
    } catch (e) {
      debugPrint('[log] : fetchCollection $e');

      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<CollectionModel> addCollection({
    required CollectionModel collection,
  }) async {
    // [TODO] : Add subcollection in db
    try {
      final response = await _firestore
          .collection(folderCollections)
          .add(collection.toJson());

      final collectionModel = collection.copyWith(id: response.id);

      return collectionModel;
    } catch (e) {
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<CollectionModel> updateCollection({
    required CollectionModel collection,
  }) async {
    // [TODO] : Add subcollection in db
    try {
      await _firestore
          .collection(folderCollections)
          .doc(collection.id)
          .set(collection.toJson());

      final collectionModel = collection;

      return collectionModel;
    } catch (e) {
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<void> deleteCollection({
    required String collectionId,
  }) async {
    // [TODO] : delete subcollection in db
    // trying bottom up approach
    try {
      final collection = await fetchCollection(
        collectionId: collectionId,
      );

      if (collection == null) {
        throw ServerException(
          message: 'Something went wrong.',
          statusCode: 400,
        );
      }

      final subCollections = collection.subcollections;

      for (final subcId in subCollections) {
        await deleteCollection(collectionId: subcId);
      }

      await _firestore
          .collection(folderCollections)
          .doc(collection.id)
          .delete();

      final urlList = collection.urls;

      for (final urlId in urlList) {
        await deleteUrlById(urlId);
      }
    } catch (e) {
      throw ServerException(
        message: 'Something went wrong.',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> fetchUrl(String urlId) async {
    try {
      Logger.printLog('fetchUrl : urlId $urlId');

      final response =
          await _firestore.collection(urlDataCollection).doc(urlId).get();
      final data = response.data();
      if (data == null) {
        throw ServerException(
          message: 'Something Went Wrong',
          statusCode: 400,
        );
      }
      data['id'] = response.id;
      final fetchedUrlData = UrlModel.fromJson(data);

      return fetchedUrlData;
    } catch (e) {
      Logger.printLog('fetchUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> addUrl(UrlModel urlModel) async {
    try {
      // Logger.printLog('UrlModel length');
      // Logger.printLog(urlModel.toJson().toString().length.toString());

      final response =
          await _firestore.collection(urlDataCollection).add(urlModel.toJson());

      final addedUrlData = urlModel.copyWith(id: response.id);

      return addedUrlData;
    } catch (e) {
      Logger.printLog('addUrlRemote : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> updateUrl({
    required UrlModel urlModel,
  }) async {
    // [TODO] : Add subcollection in db
    try {
      await _firestore
          .collection(urlDataCollection)
          .doc(urlModel.id)
          .set(urlModel.toJson());

      final urlModelUp = urlModel;

      return urlModelUp;
    } catch (e) {
      Logger.printLog('updateUrl : $e urlId: ${urlModel.id}');

      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> deleteUrl(UrlModel urlModel) async {
    try {
      // Logger.printLog('UrlModel length');
      Logger.printLog(urlModel.toString());

      await _firestore.collection(urlDataCollection).doc(urlModel.id).delete();

      return urlModel;
    } catch (e) {
      Logger.printLog('deleteUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<void> deleteUrlById(String urlId) async {
    try {
      // Logger.printLog('UrlModel length');
      // Logger.printLog(urlId);

      await _firestore.collection(urlDataCollection).doc(urlId).delete();

      return;
    } catch (e) {
      Logger.printLog('deleteUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }
}
