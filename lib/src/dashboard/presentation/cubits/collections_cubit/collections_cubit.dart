// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/app_services/databases/database_constants.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/enums/collection_loading_states.dart';

part 'collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit({
    required CollectionsRepoImpl collectionsRepoImpl,
  })  : _collectionsRepoImpl = collectionsRepoImpl,
        super(
          const CollectionsState(
            collections: {},
            collectionUrls: {},
            currentCollection: '',
            collectionLoadingStates: CollectionLoadingStates.initial,
          ),
        );

  final CollectionsRepoImpl _collectionsRepoImpl;

  Future<void> fetchCollection({
    required String collectionId,
    required String userId,
    required bool isRootCollection,
  }) async {
    // [TODO] : Fetch Subcollection
    emit(
      state.copyWith(
        currentCollection: collectionId,
        collectionLoadingStates: CollectionLoadingStates.fetching,
      ),
    );
    final fetchedCollection = isRootCollection
        ? await _collectionsRepoImpl.fetchRootCollection(
            collectionId: collectionId,
            userId: userId,
          )
        : await _collectionsRepoImpl.fetchSubCollectionAsWhole(
            collectionId: collectionId,
          );

    // ignore: cascade_invocations
    fetchedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            currentCollection: collectionId,
            collectionLoadingStates: CollectionLoadingStates.errorLoading,
          ),
        );
      },
      (tuple) {
        final (collection, subCollectionsMap, urlList) = tuple;

        // Adding Collection
        final newCollMap = {...state.collections};
        newCollMap[collectionId] = collection;
        // Adding all its subcollections
        newCollMap.addAll(subCollectionsMap);
        // Adding all the urls
        final newUrlsMap = {...state.collectionUrls};
        newUrlsMap[collection.id] = urlList;
        // updating the state
        emit(
          state.copyWith(
            currentCollection: collectionId,
            collections: newCollMap,
            collectionUrls: newUrlsMap,
            collectionLoadingStates: CollectionLoadingStates.successLoading,
          ),
        );
      },
    );
  }

  Future<void> addSubcollection({
    required CollectionModel collection,
  }) async {
    // [TODO] : Add subcollection in db
    emit(
      state.copyWith(
        currentCollection: collection.id,
        collectionLoadingStates: CollectionLoadingStates.adding,
      ),
    );
    final addedCollection = await _collectionsRepoImpl.addSubCollection(
      subCollection: collection,
    );

    addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            currentCollection: collection.id,
            collectionLoadingStates: CollectionLoadingStates.errorLoading,
          ),
        );
      },
      (collection) {
        final newCollMap = {...state.collections};
        newCollMap[collection.id] = collection;

        final newUrlsMap = {...state.collectionUrls};
        newUrlsMap[collection.id] = [];

        // update parent folder
        if (collection.parentCollection.isNotEmpty &&
            newCollMap.containsKey(collection.parentCollection)) {
          final parentColl = state.collections[collection.parentCollection];

          final subCollectoins = [...parentColl!.subcollections, collection.id];

          final updatedParentColl =
              parentColl.copyWith(subcollections: subCollectoins);

          newCollMap[parentColl.id] = updatedParentColl;
        }

        emit(
          state.copyWith(
            currentCollection: collection.id,
            collections: newCollMap,
            collectionUrls: newUrlsMap,
            collectionLoadingStates: CollectionLoadingStates.successLoading,
          ),
        );
      },
    );
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
