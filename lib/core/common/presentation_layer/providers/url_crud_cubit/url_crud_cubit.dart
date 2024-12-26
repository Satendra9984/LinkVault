import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_crud_loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/url_repo_impl.dart';

part 'url_cubit_state.dart';

class UrlCrudCubit extends Cubit<UrlCrudCubitState> {
  UrlCrudCubit({
    required CollectionsCubit collectionsCubit,
    required UrlRepoImpl urlRepoImpl,
    required GlobalUserCubit globalUserCubit,
  })  : _urlRepoImpl = urlRepoImpl,
        _collectionsCubit = collectionsCubit,
        _globalUserCubit = globalUserCubit,
        super(
          const UrlCrudCubitState(
            urlCrudLoadingStates: UrlCrudLoadingStates.initial,
          ),
        );

  final UrlRepoImpl _urlRepoImpl;
  final CollectionsCubit _collectionsCubit;
  final GlobalUserCubit _globalUserCubit;

  void cleanUp() {
    emit(
      state.copyWith(
        urlCrudLoadingStates: UrlCrudLoadingStates.initial,
      ),
    );
  }

  Future<UrlModel?> fetchSingleUrlModel(String urlModelId) async {
    UrlModel? fetchedUrlModel;

    await _urlRepoImpl
        .fetchUrlData(
      urlId: urlModelId,
      userId: _globalUserCubit.getGlobalUser()!.id,
    )
        .then(
      (res) {
        res.fold(
          (_) {},
          (urlmodel) => fetchedUrlModel = urlmodel,
        );
      },
    );

    return fetchedUrlModel;
  }

  Future<void> syncUrl({
    required UrlModel urlModel,
    required bool isRootCollection,
  }) async {
    var collection = _collectionsCubit.getCollection(
      collectionId: urlModel.collectionId,
    );

    if (collection == null) {
      await _collectionsCubit.fetchCollection(
        prentCollectionId: urlModel.collectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: isRootCollection,
      );
    }

    collection = _collectionsCubit.getCollection(
      collectionId: urlModel.collectionId,
    );

    if (collection == null || collection.collection == null) {
      return;
    }

    _collectionsCubit.updateUrlInState(
      url: UrlFetchStateModel(
        collectionId: urlModel.collectionId,
        urlModel: urlModel,
        loadingStates: LoadingStates.loading,
      ),
    );

    // DELETE URL LOCALLY
    await _urlRepoImpl
        .deleteUrlDatalocally(
      urlModelId: urlModel.firestoreId,
    )
        .then(
      (result) async {
        final syncedUrlModel = await _urlRepoImpl.fetchUrlData(
          urlId: urlModel.firestoreId,
          userId: _globalUserCubit.getGlobalUser()!.id,
        );

        syncedUrlModel.fold(
          (_) {
            _collectionsCubit.updateUrlInState(
              url: UrlFetchStateModel(
                collectionId: urlModel.collectionId,
                urlModel: urlModel,
                loadingStates: LoadingStates.loaded,
              ),
            );
          },
          (surlM) {
            _collectionsCubit.updateUrlInState(
              url: UrlFetchStateModel(
                collectionId: urlModel.collectionId,
                urlModel: urlModel,
                loadingStates: LoadingStates.loaded,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addUrl({
    required UrlModel urlData,
    required bool isRootCollection,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.adding));
    var collection = _collectionsCubit.getCollection(
      collectionId: urlData.collectionId,
    );

    if (collection == null) {
      await _collectionsCubit.fetchCollection(
        prentCollectionId: urlData.collectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: isRootCollection,
      );
    }

    collection = _collectionsCubit.getCollection(
      collectionId: urlData.collectionId,
    );

    if (collection == null || collection.collection == null) {
      return;
    }

    // Logger.printLog('[recents] : ${collection.collection!.urls}');
    // Logger.printLog('[recents] : urlid ${urlData.firestoreId}');

    // if (collection.collection!.urls.contains(urlData.firestoreId)) {
    //   Logger.printLog('[recent] : URL already exists ${urlData.firestoreId}');
    //   return;
    // }

    await _urlRepoImpl
        .addUrlData(
      collection: collection.collection!,
      urlModel: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
    )
        .then(
      (result) {
        result.fold(
          (failed) {
            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.errorAdding,
              ),
            );
          },
          (response) {
            final (urlModel, updatedParentCollection) = response;

            _collectionsCubit.addUrlInState(
              url: UrlFetchStateModel(
                collectionId: urlModel.collectionId,
                urlModel: urlModel,
                loadingStates: LoadingStates.loaded,
              ),
            );

            if (updatedParentCollection != null) {
              _collectionsCubit.updateCollectionInState(
                updatedCollection: updatedParentCollection,
              );
            }

            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.addedSuccessfully,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.updating));

    await _urlRepoImpl
        .updateUrl(
      urlModel: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
    )
        .then(
      (result) async {
        await result.fold(
          (failed) {
            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.errorupdating,
              ),
            );
          },
          (response) async {
            // final urlModel = response;

            _collectionsCubit.updateUrlInState(
              url: UrlFetchStateModel(
                collectionId: urlData.collectionId,
                urlModel: urlData,
                loadingStates: LoadingStates.loaded,
              ),
            );

            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.updatedSuccessfully,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> deleteUrl({
    required UrlModel urlData,
    required bool isRootCollection,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.deleting));

    var collection =
        _collectionsCubit.getCollection(collectionId: urlData.collectionId);

    if (collection == null || collection.collection == null) {
      await _collectionsCubit.fetchCollection(
        prentCollectionId: urlData.collectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: isRootCollection,
      );
    }

    collection =
        _collectionsCubit.getCollection(collectionId: urlData.collectionId);

    if (collection == null || collection.collection == null) {
      emit(
        state.copyWith(
          urlCrudLoadingStates: UrlCrudLoadingStates.errordeleting,
        ),
      );
      return;
    }

    await _urlRepoImpl
        .deleteUrlData(
      collection: collection.collection!,
      urlData: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
    )
        .then(
      (result) {
        result.fold(
          (failed) {
            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.errordeleting,
              ),
            );
          },
          (response) async {
            final (isDeleted, updatedParentCollection) = response;

            _collectionsCubit.deleteUrlInState(url: urlData);

            if (updatedParentCollection != null) {
              _collectionsCubit.updateCollectionInState(
                updatedCollection: updatedParentCollection,
              );
            }

            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.deletedSuccessfully,
              ),
            );
          },
        );
      },
    );
  }
}
