import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class RemoteDataSourcesImpl {
  RemoteDataSourcesImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

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
      // debugPrint('[log] : fetchCollection $e');

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
    // Add subcollection in db
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

  Future<UrlModel> fetchUrl(
    String urlId, {
    required String userId,
  }) async {
    try {
      // // Logger.printLog('fetchUrl : urlId $urlId');

      final response = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection(urlDataCollection)
          .doc(urlId)
          .get();
      final data = response.data();
      if (data == null) {
        // // Logger.printLog('Url data is null');
        throw ServerException(
          message: 'Something Went Wrong',
          statusCode: 400,
        );
      }
      data['id'] = response.id;
      final fetchedUrlData = UrlModel.fromJson(data);

      return fetchedUrlData;
    } catch (e) {
      // // Logger.printLog('fetchUrl : $e');
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }
}
