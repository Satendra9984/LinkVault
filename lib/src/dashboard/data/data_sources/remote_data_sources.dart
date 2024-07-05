import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

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
      throw ServerException(
        message: 'Something Went Wrong',
        statusCode: 400,
      );
    }
  }

  // Future<void> fetchSubCollection({
  //   required String subCollectionId,
  // }) async {
  //   // [TODO] : Fetch Subcollection
  // }

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

  Future<void> deleteSubCollection({
    required String subcollectionId,
  }) async {
    // [TODO] : delete subcollection in db
  }

  Future<void> updateSubCollection({
    required CollectionModel subcollection,
  }) async {
    // [TODO] : update subcollection in db
  }
}
