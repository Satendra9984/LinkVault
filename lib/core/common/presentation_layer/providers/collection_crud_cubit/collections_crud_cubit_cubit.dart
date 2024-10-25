// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/common/repository_layer/enums/collection_crud_loading_states.dart';

part 'collections_crud_cubit_state.dart';

class CollectionCrudCubit extends Cubit<CollectionCrudCubitState> {
  CollectionCrudCubit({
    required CollectionsCubit collectionsCubit,
    required CollectionsRepoImpl collectionRepoImpl,
    required GlobalUserCubit globalUserCubit,
  })  : _collectionRepoImpl = collectionRepoImpl,
        _collectionsCubit = collectionsCubit,
        _globalUserCubit = globalUserCubit,
        super(
          const CollectionCrudCubitState(
            collectionCrudLoadingStates: CollectionCrudLoadingStates.initial,
          ),
        );

  final CollectionsRepoImpl _collectionRepoImpl;
  final CollectionsCubit _collectionsCubit;
  final GlobalUserCubit _globalUserCubit;

  void cleanUp() {
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.initial,
      ),
    );
  }

  Future<void> addCollection({
    required CollectionModel collection,
  }) async {
    // [TODO] : Add subcollection in db
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.adding,
      ),
    );

    final parentCollection = _collectionsCubit.getCollection(
      collectionId: collection.parentCollection,
    );

    // WE are updating the parent collection and sending to db request to save
    // query time and less points of server errors
    final addedCollection = await _collectionRepoImpl.addCollection(
      subCollection: collection,
      parentCollection: parentCollection!.collection,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    await addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.errorAdding,
          ),
        );
      },
      (result) async {
        final (collection, updatedParentCollection) = result;

        _collectionsCubit.addCollection(collection: collection);

        if (updatedParentCollection != null) {
          _collectionsCubit.updateCollection(
            updatedCollection: updatedParentCollection,
            fetchSubCollIndexAdded: 1,
          );
        }

        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.addedSuccessfully,
          ),
        );

        await addCollectionToFavourites(collection: collection);
      },
    );
  }

  Future<void> deleteCollection({
    required CollectionModel collection,
  }) async {
    // delete subcollection in db it will be cascade delete
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.deleting,
      ),
    );

    var parentCollection = _collectionsCubit.getCollection(
      collectionId: collection.parentCollection,
    );

    if (parentCollection == null) {
      await _collectionsCubit.fetchCollection(
        collectionId: collection.parentCollection,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: false,
      );
    }

    parentCollection = _collectionsCubit.getCollection(
      collectionId: collection.parentCollection,
    );

    if (parentCollection == null) {
      emit(
        state.copyWith(
          collectionCrudLoadingStates:
              CollectionCrudLoadingStates.errordeleting,
        ),
      );

      return;
    }

    // WE are updating the parent collection and sending to db request to save
    // query time and less points of server errors
    final deletedCollection = await _collectionRepoImpl.deleteCollection(
      collectionId: collection.id,
      parentCollectionId: parentCollection.collection!.id,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    await deletedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.errordeleting,
          ),
        );
      },
      (result) async {
        final (collection, updatedParentCollection) = result;

        await _collectionRepoImpl.updateSubCollection(
          subCollection: updatedParentCollection,
          userId: _globalUserCubit.state.globalUser!.id,
        );

        _collectionsCubit
          ..deleteCollection(collection: collection)
          ..updateCollection(
            updatedCollection: updatedParentCollection,
            fetchSubCollIndexAdded: -1,
          );

        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.deletedSuccessfully,
          ),
        );

        await deleteCollectionToFavourites(
          collection: collection,
        );
      },
    );
  }

  Future<void> updateCollection({
    required CollectionModel collection,
  }) async {
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.updating,
      ),
    );

    final addedCollection = await _collectionRepoImpl.updateSubCollection(
      subCollection: collection,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    await addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.errorupdating,
          ),
        );
      },
      (updatedCollection) async {
        _collectionsCubit.updateCollection(
          updatedCollection: updatedCollection,
          fetchSubCollIndexAdded: 0,
        );

        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.updatedSuccessfully,
          ),
        );

        await updateCollectionToFavourites(collection: collection);
      },
    );
  }

  // <-------------------------- FAVOURITES ------------------------------------>

  Future<void> addCollectionToFavourites({
    required CollectionModel collection,
  }) async {
    final status = collection.status ?? {};
    final isFav = status['is_favourite'] ?? false;

    if (isFav == false) return;

    // [TODO] : CHECK IF FAVOURITES IS PRESENT IN STATE OR NOT
    final favouriteCollectionId =
        '${_globalUserCubit.getGlobalUser()!.id}$favourites';
    var favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    // IF NOT THEN FETCH IT FROM REPO AS ROOT COLLECTION (IMPTORTANT)
    // AND ADD TO THE COLLECTIONS
    if (favouriteCollection == null) {
      await _collectionRepoImpl
          .fetchRootCollection(
        collectionId: favouriteCollectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        collectionName: favourites,
      )
          .then(
        (result) {
          result.fold(
            (failed) => null,
            (fetched) {
              _collectionsCubit.addCollection(collection: fetched);
            },
          );
        },
      );
    }

    // CHECK AGAIN IF NOT PRESENT THEN SOME ERROR OCCURED
    favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    if (favouriteCollection == null) return;

    final favouriteCollectionsList = [
      collection.id,
      ...favouriteCollection.collection!.subcollections,
    ];

    final updatedFavouriteCollection = favouriteCollection.collection!.copyWith(
      subcollections: favouriteCollectionsList,
    );

    await _collectionRepoImpl.updateSubCollection(
      subCollection: updatedFavouriteCollection,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    _collectionsCubit.updateCollection(
      updatedCollection: updatedFavouriteCollection,
      fetchSubCollIndexAdded: 1,
    );
  }

  Future<void> updateCollectionToFavourites({
    required CollectionModel collection,
  }) async {
    final status = collection.status ?? {};
    final isFav = status['is_favourite'] as bool? ?? false;

    // if (isFav == false) return;

    // [TODO] : CHECK IF FAVOURITES IS PRESENT IN STATE OR NOT
    final favouriteCollectionId =
        '${_globalUserCubit.getGlobalUser()!.id}$favourites';
    var favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    // IF NOT THEN FETCH IT FROM REPO AS ROOT COLLECTION (IMPTORTANT)
    // AND ADD TO THE COLLECTIONS
    if (favouriteCollection == null) {
      await _collectionRepoImpl
          .fetchRootCollection(
        collectionId: favouriteCollectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        collectionName: favourites,
      )
          .then(
        (result) {
          result.fold(
            (failed) => null,
            (fetched) {
              _collectionsCubit.addCollection(collection: fetched);
            },
          );
        },
      );
    }
    // CHECK AGAIN IF NOT PRESENT THEN SOME ERROR OCCURED
    favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    if (favouriteCollection == null) return;

    final isCollectionAlreadyPresentInList =
        favouriteCollection.collection!.subcollections.contains(
      collection.id,
    );

    if (isCollectionAlreadyPresentInList && isFav == false) {
      await deleteCollectionToFavourites(collection: collection);
    } else if (isCollectionAlreadyPresentInList == false && isFav) {
      await addCollectionToFavourites(collection: collection);
    }
  }

  Future<void> deleteCollectionToFavourites({
    required CollectionModel collection,
  }) async {
    final status = collection.status ?? {};
    final isFav = status['is_favourite'] ?? false;

    // if (isFav == false) return;

    // [TODO] : CHECK IF FAVOURITES IS PRESENT IN STATE OR NOT
    final favouriteCollectionId =
        '${_globalUserCubit.getGlobalUser()!.id}$favourites';
    var favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    // IF NOT THEN FETCH IT FROM REPO AS ROOT COLLECTION (IMPTORTANT)
    // AND ADD TO THE COLLECTIONS
    if (favouriteCollection == null) {
      await _collectionRepoImpl
          .fetchRootCollection(
        collectionId: favouriteCollectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        collectionName: favourites,
      )
          .then(
        (result) {
          result.fold(
            (failed) => null,
            (fetched) {
              _collectionsCubit.addCollection(collection: fetched);
            },
          );
        },
      );
    }
    // CHECK AGAIN IF NOT PRESENT THEN SOME ERROR OCCURED
    favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    if (favouriteCollection == null) return;

    final favouriteCollectionsList = [
      ...favouriteCollection.collection!.subcollections,
    ]..removeWhere((element) => element == collection.id);

    final updatedFavouriteCollection = favouriteCollection.collection!.copyWith(
      subcollections: favouriteCollectionsList,
    );

    await _collectionRepoImpl.updateSubCollection(
      subCollection: updatedFavouriteCollection,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    // [TODO] : HANDLE UPDATION LOGIC
    final alreadyFetchedFavouriteIndexes =
        favouriteCollection.subCollectionFetchedIndex;

    if (alreadyFetchedFavouriteIndexes < 0) {
      _collectionsCubit.updateCollection(
        updatedCollection: updatedFavouriteCollection,
        fetchSubCollIndexAdded: 0,
      );
    } else {
      final sublist = favouriteCollection.collection!.subcollections.sublist(
        0,
        alreadyFetchedFavouriteIndexes + 1,
      );

      if (sublist.contains(collection.id)) {
        _collectionsCubit.updateCollection(
          updatedCollection: updatedFavouriteCollection,
          fetchSubCollIndexAdded: -1,
        );
      } else {
        _collectionsCubit.updateCollection(
          updatedCollection: updatedFavouriteCollection,
          fetchSubCollIndexAdded: 0,
        );
      }
    }
  }
}
