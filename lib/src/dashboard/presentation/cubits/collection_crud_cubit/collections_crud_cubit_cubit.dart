import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/enums/collection_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';

part 'collections_crud_cubit_state.dart';

class CollectionCrudCubit extends Cubit<CollectionCrudCubitState> {
  CollectionCrudCubit({
    required CollectionsCubit collectionsCubit,
    required CollectionsRepoImpl collectionRepoImpl,
  })  : _collectionRepoImpl = collectionRepoImpl,
        _collectionsCubit = collectionsCubit,
        super(
          const CollectionCrudCubitState(
            collectionCrudLoadingStates: CollectionCrudLoadingStates.initial,
          ),
        );

  final CollectionsRepoImpl _collectionRepoImpl;
  final CollectionsCubit _collectionsCubit;

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
    );

    addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.errorAdding,
          ),
        );
      },
      (result) {
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
      },
    );
  }

  Future<void> deleteCollection({
    required CollectionModel collection,
  }) async {
    // [TODO] : delete subcollection in db it will be cascade delete

    Logger.printLog(
      'deleting collection ${collection.id}',
    );
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.deleting,
      ),
    );

    final parentCollection = _collectionsCubit.getCollection(
      collectionId: collection.parentCollection,
    );

    // WE are updating the parent collection and sending to db request to save
    // query time and less points of server errors
    final deletedCollection = await _collectionRepoImpl.deleteCollection(
      collection: collection,
      parentCollection: parentCollection!.collection!,
    );

    deletedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.errordeleting,
          ),
        );
      },
      (result) {
        final (collection, updatedParentCollection) = result;

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
      },
    );
  }

  Future<void> updateCollection({
    required CollectionModel collection,
  }) async {
    // [TODO] : update subcollection in db
    emit(
      state.copyWith(
        collectionCrudLoadingStates: CollectionCrudLoadingStates.updating,
      ),
    );

    final addedCollection = await _collectionRepoImpl.updateSubCollection(
      subCollection: collection,
    );

    addedCollection.fold(
      (failed) {
        emit(
          state.copyWith(
            collectionCrudLoadingStates:
                CollectionCrudLoadingStates.errorupdating,
          ),
        );
      },
      (updatedCollection) {
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
      },
    );
  }
}
