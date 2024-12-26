// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/collection_crud_loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';

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

  Future<void> syncCollection({
    required CollectionModel collectionModel,
    required bool isRootCollection,
  }) async {
    var collection = _collectionsCubit.getCollection(
      collectionId: collectionModel.id,
    );

    if (collection == null) {
      await _collectionsCubit.fetchCollection(
        prentCollectionId: collectionModel.id,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: isRootCollection,
      );
    }

    collection = _collectionsCubit.getCollection(
      collectionId: collectionModel.id,
    );

    if (collection == null || collection.collection == null) {
      return;
    }

    _collectionsCubit.updateCollectionInState(
      updatedCollection: collectionModel,
      collectionFetchState: LoadingStates.loading,
    );

    // DELETE URL LOCALLY
    await _collectionRepoImpl
        .deleteCollectionLocally(
      collectionId: collection.collection!.id,
      parentCollectionId: collection.collection!.parentCollection,
    )
        .then(
      (result) async {
        final fetchedCollection = isRootCollection
            ? await _collectionRepoImpl.fetchRootCollection(
                collectionId: collection!.collection!.id,
                userId: _globalUserCubit.getGlobalUser()!.id,
                collectionName: collectionModel.name,
              )
            : await _collectionRepoImpl.fetchSubCollection(
                collectionId: collection!.collection!.id,
                userId: _globalUserCubit.state.globalUser!.id,
              );

        _collectionsCubit.deleteCollectionInState(
            collection: collection.collection!);

        // ignore: cascade_invocations
        fetchedCollection.fold(
          (_) {
            _collectionsCubit.updateCollectionInState(
              updatedCollection: collectionModel,
              collectionFetchState: LoadingStates.loaded,
            );
          },
          (syncedColl) {
            _collectionsCubit.addSubCollectionInState(
              collection: syncedColl,
            );
          },
        );
      },
    );
  }

  Future<void> addCollection({
    required CollectionModel collection,
  }) async {
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.adding,
      ),
    );

    // WE are updating the parent collection and sending to db request to save
    // query time and less points of server errors
    final addedCollection = await _collectionRepoImpl.addCollection(
      collection: collection,
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
        final collection = result;

        _collectionsCubit.addSubCollectionInState(collection: result.$1);
        if (result.$2 != null) {
          _collectionsCubit.updateCollectionInState(
            updatedCollection: result.$2!,
          );
        }

        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.addedSuccessfully,
          ),
        );
      },
    );
  }

  Future<void> deleteCollection({
    required CollectionModel collection,
    required bool isRootCollection,
  }) async {
    // delete subcollection in db it will be cascade delete
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.deleting,
      ),
    );

    var parentCollection = _collectionsCubit.getCollection(
      collectionId:
          isRootCollection ? collection.id : collection.parentCollection,
    );

    if (parentCollection == null && !isRootCollection) {
      await _collectionsCubit.fetchCollection(
        prentCollectionId:
            isRootCollection ? collection.id : collection.parentCollection,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: false,
      );
    }

    parentCollection = _collectionsCubit.getCollection(
      collectionId:
          isRootCollection ? collection.id : collection.parentCollection,
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
      collection: collection,
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
        final (isDeleted, updatedParentCollection) = result;
        _collectionsCubit.deleteCollectionInState(collection: collection);

        if (updatedParentCollection != null) {
          _collectionsCubit.updateCollectionInState(
            updatedCollection: updatedParentCollection,
          );
        }

        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.deletedSuccessfully,
          ),
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
      collection: collection,
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
        _collectionsCubit.updateCollectionInState(
          updatedCollection: updatedCollection,
        );

        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.updatedSuccessfully,
          ),
        );
      },
    );
  }
}
