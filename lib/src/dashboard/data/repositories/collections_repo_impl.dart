import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

class CollectionsRepoImpl {
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
    required CollectionModel subCollection,
  }) async {
    // [TODO] : delete subcollection in db
  }

  Future<void> updateSubCollection({
    required CollectionModel subCollection,
  }) async {
    // [TODO] : update subcollection in db
  }
}
