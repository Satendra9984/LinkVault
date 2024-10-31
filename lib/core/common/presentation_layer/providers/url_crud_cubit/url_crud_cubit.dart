import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_crud_loading_states.dart';
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
        collectionId: urlModel.collectionId,
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

    _collectionsCubit.updateUrl(
      url: urlModel,
      urlLoadinState: LoadingStates.loading,
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
            _collectionsCubit.updateUrl(
              url: urlModel,
              urlLoadinState: LoadingStates.loaded,
            );
          },
          (surlM) {
            _collectionsCubit.updateUrl(
              url: surlM,
              urlLoadinState: LoadingStates.loaded,
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
        collectionId: urlData.collectionId,
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

    await _urlRepoImpl
        .addUrlData(
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
                urlCrudLoadingStates: UrlCrudLoadingStates.errorAdding,
              ),
            );
          },
          (response) {
            final (urlData, collection) = response;

            _collectionsCubit.addUrl(url: urlData, collection: collection);

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
      urlData: urlData,
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
            final urlData = response;

            _collectionsCubit.updateUrl(url: urlData);

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
        collectionId: urlData.collectionId,
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
            final (urlData, _) = response;

            _collectionsCubit.deleteUrl(
              url: urlData,
              collectionModel: collection!.collection!,
            );

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
