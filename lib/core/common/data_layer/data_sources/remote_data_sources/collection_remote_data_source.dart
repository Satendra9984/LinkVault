import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/query_builder.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class RemoteDataSourcesImpl {
  RemoteDataSourcesImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<CollectionModel>?> fetchCollectionsFromRemoteDB({
    required String userId,
    required CollectionFilter filter,
  }) async {
    // [TODO] : Fetch Subcollection
    try {
      final query = QueryBuilderHelper.buildCollectionModelFirestoreQuery(
        userId: userId,
        firestore: _firestore,
        collectionFilter: filter,
      );

      final querySnapshot = await query.get();
      // Logger.printLog(
      //     'path: ${response.reference.path}, data: ${data == null}');
      final data = querySnapshot.docs;

      final collections = data
          .map(
            (doc) => CollectionModel.fromJson(
              {'id': doc.id, ...doc.data()},
            ),
          )
          .toList();

      return collections;
    } catch (e) {
      debugPrint('[log] : fetchCollection $e');

      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  /// It will use `userId` to fetch root collection currently
  Future<CollectionModel?> fetchCollectionFromRemoteDB({
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

  Future<CollectionModel> addCollectionInRemoteDB({
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

  Future<CollectionModel> updateCollectionInRemoteDB({
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

  Future<void> deleteCollectionAndAssociatedData({
    required String userId,
    required String collectionId,
    int batchSize = 30,
  }) async {
    var isMainCollectionDeleted = false;
    try {
      // 1. First delete the parent collection document
      await Future.wait([
        Future(() async {
          await _firestore
              .collection(userCollection)
              .doc(userId)
              .collection(folderCollections)
              .doc(collectionId)
              .delete();
          isMainCollectionDeleted = true;
        }),

        // 2. Delete all URLs associated with this collection
        _deleteUrlsForCollection(
          userId: userId,
          collectionId: collectionId,
          batchSize: batchSize,
        ),
      ]);

      var batch = _firestore.batch();
      var operationCount = 0;

      // Queue for processing subcollections
      final collectionsToProcess = Queue<String>()..add(collectionId);

      while (collectionsToProcess.isNotEmpty) {
        final currentCollectionId = collectionsToProcess.removeFirst();

        // Get subcollections
        final subcollections = await _firestore
            .collection(userCollection)
            .doc(userId)
            .collection(folderCollections)
            .where('parent_collection', isEqualTo: currentCollectionId)
            .get();

        for (final doc in subcollections.docs) {
          // Add to queue for processing its subcollections
          collectionsToProcess.add(doc.id);

          // Delete the collection document
          batch.delete(doc.reference);
          operationCount++;

          if (operationCount >= batchSize) {
            // Run batch commit and URL deletion in parallel
            await Future.wait([
              batch.commit(),
              _deleteUrlsForCollection(
                userId: userId,
                collectionId: doc.id,
                batchSize: batchSize,
              ),
            ]);

            // Reset batch after commit
            batch = _firestore.batch();
            operationCount = 0;
          } else {
            // If batch isn't full, just delete URLs
            await _deleteUrlsForCollection(
              userId: userId,
              collectionId: doc.id,
              batchSize: batchSize,
            );
          }
        }
      }

      // Commit any remaining deletions
      if (operationCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('[log] : Error in deletion: $e');
      if (isMainCollectionDeleted == true) {
        return;
      }
      throw ServerException(
        message: 'Failed to delete collection and associated data',
        statusCode: 500,
      );
    }
  }

  // Helper method to delete URLs for a specific collection
  Future<void> _deleteUrlsForCollection({
    required String userId,
    required String collectionId,
    required int batchSize,
  }) async {
    var batch = _firestore.batch();
    var operationCount = 0;

    try {
      // Get all URLs for this collection
      final urlsSnapshot = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .where('collection_id', isEqualTo: collectionId)
          .get();

      for (final urlDoc in urlsSnapshot.docs) {
        batch.delete(urlDoc.reference);
        operationCount++;

        if (operationCount >= batchSize) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      // Commit any remaining URL deletions
      if (operationCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('[log] : Error deleting URLs: $e');
      throw ServerException(
        message: 'Failed to delete associated URLs',
        statusCode: 500,
      );
    }
  }

  Future<UrlModel> addUrlInRemoteDB(
    UrlModel urlModel, {
    required String userId,
  }) async {
    try {
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

  Future<void> updateUrlInRemoteDB({
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

      return;
    } catch (e) {
      // Logger.printLog('[RECENTS] : updateUrl : $e urlId: ${urlModel.firestoreId}');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  Future<String> deleteUrlInRemoteDB({
    required String urlId,
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
}
