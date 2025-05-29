import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:link_vault/src/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/src/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/src/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class RemoteDataSourcesImpl {
  RemoteDataSourcesImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<CollectionModel?> fetchCollection({
    required String collectionId,
    required String userId,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final response = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(folderCollections)
          .doc(collectionId)
          .get();

      // // Logger.printLog('path: ${response.reference.path}, ');

      final data = response.data();
      // // Logger.printLog(
      //     'path: ${response.reference.path}, data: ${data == null}');

      if (data == null) {
        // That mean user is using it first time may be
        return null;
      }

      // user is not using first time
      data['id'] = response.id;
      // // Logger.printLog(StringUtils.getJsonFormat(data));

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
    required String userId,
  }) async {
    // [TODO] : Add subcollection in db
    try {
      final response = await _firestore
          .collection(userCollection)
          .doc(userId)
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
    required String userId,
  }) async {
    // [TODO] : Add subcollection in db
    try {
      await _firestore
          .collection(userCollection)
          .doc(userId)
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
    required String userId,
    void Function({required String collectionId})? locaDBDelete,
  }) async {
    // [TODO] : delete subcollection in db
    // trying bottom up approach
    try {
      final collection = await fetchCollection(
        collectionId: collectionId,
        userId: userId,
      );

      if (collection == null) {
        throw ServerException(
          message: 'Something went wrong.',
          statusCode: 400,
        );
      }

      final subCollections = collection.subcollections;

      for (final subcId in subCollections) {
        await deleteCollection(
          collectionId: subcId,
          userId: userId,
        );
      }

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(folderCollections)
          .doc(collection.id)
          .delete();

      final urlList = collection.urls;

      for (final urlId in urlList) {
        await deleteUrlById(
          urlId,
          userId: urlId,
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Something went wrong.',
        statusCode: 400,
      );
    }
  }

  Future<void> deleteCollectionSingle({
    required String collectionId,
    required String userId,
  }) async {
    // [TODO] : delete subcollection in db
    // trying bottom up approach
    try {
      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(folderCollections)
          .doc(collectionId)
          .delete();
    } catch (e) {
      throw ServerException(
        message: 'Something went wrong.',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> fetchUrl(
    String urlId, {
    required String userId,
  }) async {
    try {
      // Logger.printLog('fetchUrl : urlId $urlId');

      final response = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlId)
          .get();

      final data = response.data();

      if (data == null) {
        // Logger.printLog('Url data is null');
        throw ServerException(
          message: 'Something Went Wrong',
          statusCode: 400,
        );
      }
      data['id'] = response.id;
      final fetchedUrlData = UrlModel.fromJson(data);

      return fetchedUrlData;
    } catch (e) {
      // Logger.printLog('fetchUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> addUrl(
    UrlModel urlModel, {
    required String userId,
  }) async {
    try {
      // Logger.printLog('UrlModel length');
      // Logger.printLog(urlModel.toJson().toString().length.toString());
      // await  _firestore.enableNetwork();
      final response = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .add(urlModel.toJson());

      final addedUrlData = urlModel.copyWith(firestoreId: response.id);

      return addedUrlData;
    } catch (e) {
      // Logger.printLog('addUrlRemote : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<UrlModel> updateUrl({
    required UrlModel urlModel,
    required String userId,
  }) async {
    // Add subcollection in db
    try {
      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlModel.firestoreId)
          .set(urlModel.toJson());

      final urlModelUp = urlModel;

      return urlModelUp;
    } catch (e) {
      // Logger.printLog('[RECENTS] : updateUrl : $e urlId: ${urlModel.firestoreId}');

      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<String> deleteUrl(
    String urlId, {
    required String userId,
  }) async {
    try {
      // Logger.printLog('UrlModel length');
      // Logger.printLog(urlId);

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlId)
          .delete();

      return urlId;
    } catch (e) {
      // Logger.printLog('deleteUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<void> deleteUrlById(
    String urlId, {
    required String userId,
  }) async {
    try {

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlId)
          .delete();

      return;
    } catch (e) {
      // Logger.printLog('deleteUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }
}
