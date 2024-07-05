// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
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
            currentCollection: '',
            collectionLoadingStates: CollectionLoadingStates.initial,
          ),
        );

  final CollectionsRepoImpl _collectionsRepoImpl;

  Future<void> fetchRootCollection({
    required String collectionId,
    required String userId, // it will be user id
    required String collectionName, // it will be user id
    // it will be user id
  }) async {
    // [TODO] : Fetch Subcollection

    if (state.collections.containsKey(collectionId)) {
      emit(
        state.copyWith(
          currentCollection: collectionId,
          collectionLoadingStates: CollectionLoadingStates.successLoading,
        ),
      );
      return;
    }

    // Else need to fetch data from the database

    emit(
      state.copyWith(
        currentCollection: collectionId,
        collectionLoadingStates: CollectionLoadingStates.fetching,
      ),
    );
    final fetchedCollection = await _collectionsRepoImpl.fetchRootCollection(
      collectionId: collectionId,
      userId: userId,
    );

    fetchedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            currentCollection: collectionId,
            collectionLoadingStates: CollectionLoadingStates.errorLoading,
          ),
        );
      },
      (collection) {
        final newCollMap = {...state.collections};
        newCollMap[collectionId] = collection;

        emit(
          state.copyWith(
            currentCollection: collectionId,
            collections: newCollMap,
            collectionLoadingStates: CollectionLoadingStates.successLoading,
          ),
        );
      },
    );
  }

  Future<void> fetchCollection({
    required String collectionId,
  }) async {
    // [TODO] : Fetch Subcollection
    emit(
      state.copyWith(
        currentCollection: collectionId,
        collectionLoadingStates: CollectionLoadingStates.fetching,
      ),
    );
    final fetchedCollection = await _collectionsRepoImpl.fetchSubCollection(
      collectionId: collectionId,
    );

    await fetchedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            currentCollection: collectionId,
            collectionLoadingStates: CollectionLoadingStates.errorLoading,
          ),
        );
      },
      (collection) async {
        final newCollMap = {...state.collections};
        newCollMap[collectionId] = collection;

        for (var subColl in collection.subcollections) {
          final fetchedCollection =
              await _collectionsRepoImpl.fetchSubCollection(
            collectionId: collectionId,
          );
        }

        emit(
          state.copyWith(
            currentCollection: collectionId,
            collections: newCollMap,
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
