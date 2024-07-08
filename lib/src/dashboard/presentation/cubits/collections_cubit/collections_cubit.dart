// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/utils/logger.dart';
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
    if (state.collections.containsKey(collectionId)) {
      // Logger.printLog('collectionId $collectionId already exists');
      var containsAllSubColl = true;
      final coll = state.collections[collectionId]!;
      for (final subcId in coll.subcollections) {
        if (state.collections.containsKey(subcId) == false) {
          containsAllSubColl = false;
          break;
        }
      }

      if (containsAllSubColl) {
        return;
      }
    }

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
        currentCollection: collection.parentCollection,
        collectionLoadingStates: CollectionLoadingStates.adding,
      ),
    );

    final parentCollection = state.collections[collection.parentCollection];

    // WE are updating the parent collection and sending to db request to save
    // query time and less points of server errors
    final addedCollection = await _collectionsRepoImpl.addSubCollection(
      subCollection: collection,
      parentCollection: parentCollection,
    );

    addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            currentCollection: collection.parentCollection,
            collectionLoadingStates: CollectionLoadingStates.errorAdding,
          ),
        );
      },
      (result) {
        final (collection, updatedParentCollection) = result;
        final newCollMap = {...state.collections};
        newCollMap[collection.id] = collection;
        if (updatedParentCollection != null) {
          newCollMap[updatedParentCollection.id] = updatedParentCollection;
        }

        final newUrlsMap = {...state.collectionUrls};
        newUrlsMap[collection.id] = [];

        emit(
          state.copyWith(
            currentCollection: collection.parentCollection,
            collections: newCollMap,
            collectionUrls: newUrlsMap,
            collectionLoadingStates: CollectionLoadingStates.successAdding,
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
    required CollectionModel collection,
  }) async {
    // [TODO] : update subcollection in db
    emit(
      state.copyWith(
        currentCollection: collection.parentCollection,
        collectionLoadingStates: CollectionLoadingStates.updating,
      ),
    );

    final addedCollection = await _collectionsRepoImpl.updateSubCollection(
      subCollection: collection,
    );

    addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            currentCollection: collection.parentCollection,
            collectionLoadingStates: CollectionLoadingStates.errorUpdating,
          ),
        );
      },
      (updatedCollection) {
        final newCollMap = {...state.collections};
        newCollMap[collection.id] = updatedCollection;

        emit(
          state.copyWith(
            currentCollection: collection.parentCollection,
            collections: newCollMap,
            collectionLoadingStates: CollectionLoadingStates.successUpdating,
          ),
        );
      },
    );
  }
}
