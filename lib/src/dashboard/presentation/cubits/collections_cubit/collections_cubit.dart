// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

part 'collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit()
      : super(
          const CollectionsState(
            collections: {},
          ),
        );

  Future<void> fetchRootCollection({
    required String subcollectionId, // it will be user id
  }) async {
    // [TODO] : Fetch Subcollection
  }

  Future<void> fetchSubCollection({
    required String subcollectionId,
  }) async {
    // [TODO] : Fetch Subcollection
  }

  Future<void> addSubcollection({
    required String subcollectionName,
    required String category,
    required bool isFavourite,
    String? subcollectionDescription,
  }) async {
    // [TODO] : Add subcollection in db
  }

  Future<void> deleteSubcollection({
    required CollectionModel subcollection,
  }) async {
    // [TODO] : delete subcollection in db it will be cascade delete
  }

  Future<void> updateSubcollection({
    required CollectionModel subcollection,
  }) async {
    // [TODO] : update subcollection in db
  }
}
