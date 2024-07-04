import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

class RemoteDataSourcesImpl {
  RemoteDataSourcesImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> fetchSubCollection({
    required String subCollectionId,
  }) async {
    // [TODO] : Fetch Subcollection
  }

  Future<void> addSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : Add subcollection in db
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
