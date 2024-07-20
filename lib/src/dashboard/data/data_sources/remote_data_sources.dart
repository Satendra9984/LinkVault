import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class RemoteDataSourcesImpl {
  RemoteDataSourcesImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> rebaseCollections() async {
    await _firestore.collection(folderCollections).get().then((qsnp) async {
      for (final doc in qsnp.docs) {
        final data = doc.data();

        await _firestore
            .collection(userCollection)
            .doc('hzx1SlJoeyRcnEvTx0U1OdkXMEQ2')
            .collection(folderCollections)
            .doc(doc.id)
            .set(data);
      }
    });

    await _firestore.collection(urlDataCollection).get().then(
      (qsnp) async {
        for (final doc in qsnp.docs) {
          doc.data();

          await _firestore
              .collection(userCollection)
              .doc('hzx1SlJoeyRcnEvTx0U1OdkXMEQ2')
              .collection(urlDataCollection)
              .doc(doc.id)
              .set(doc.data());
        }
      },
    );
  }

  /// It will use `userId` to fetch root collection currently
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

      // Logger.printLog('path: ${response.reference.path}, ');

      final data = response.data();
      // Logger.printLog(
      //     'path: ${response.reference.path}, data: ${data == null}');

      if (data == null) {
        // That mean user is using it first time may be
        return null;
      }

      // user is not using first time
      data['id'] = response.id;
      // Logger.printLog(StringUtils.getJsonFormat(data));

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
        Logger.printLog('Url data is null');
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

  Future<UrlModel> addUrl(
    UrlModel urlModel, {
    required String userId,
  }) async {
    try {
      // Logger.printLog('UrlModel length');
      // Logger.printLog(urlModel.toJson().toString().length.toString());

      final response = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .add(urlModel.toJson());

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
    required String userId,
  }) async {
    // [TODO] : Add subcollection in db
    try {
      await _firestore
          .collection(userCollection)
          .doc(userId)
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

  Future<UrlModel> deleteUrl(
    UrlModel urlModel, {
    required String userId,
  }) async {
    try {
      // Logger.printLog('UrlModel length');
      Logger.printLog(urlModel.toString());

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlModel.id)
          .delete();

      return urlModel;
    } catch (e) {
      Logger.printLog('deleteUrl : $e');
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
      // Logger.printLog('UrlModel length');
      // Logger.printLog(urlId);

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlId)
          .delete();

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
