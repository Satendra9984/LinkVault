import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/constants/database_constants.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/enums/url_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';

part 'url_cubit_state.dart';

class UrlCrudCubit extends Cubit<UrlCrudCubitState> {
  UrlCrudCubit({
    required CollectionsCubit collectionsCubit,
    required UrlRepoImpl urlRepoImpl,
    required CollectionsRepoImpl collectionRepoImpl,
    required GlobalUserCubit globalUserCubit,
  })  : _urlRepoImpl = urlRepoImpl,
        _collectionRepoImpl = collectionRepoImpl,
        _collectionsCubit = collectionsCubit,
        _globalUserCubit = globalUserCubit,
        super(
          const UrlCrudCubitState(
            urlCrudLoadingStates: UrlCrudLoadingStates.initial,
          ),
        );

  final UrlRepoImpl _urlRepoImpl;
  final CollectionsRepoImpl _collectionRepoImpl;

  final CollectionsCubit _collectionsCubit;
  final GlobalUserCubit _globalUserCubit;

  void cleanUp() {
    emit(
      state.copyWith(
        urlCrudLoadingStates: UrlCrudLoadingStates.initial,
      ),
    );
  }

  Future<void> addUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.adding));
    final collection = _collectionsCubit.getCollection(
      collectionId: urlData.collectionId,
    );

    await _urlRepoImpl
        .addUrlData(
      collection: collection!.collection!,
      urlData: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
    )
        .then((result) {
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

          addURLToFavourites(urlData: urlData);
        },
      );
    });
  }

  Future<void> updateUrl({
    required UrlModel urlData,
  }) async {
    // await updateURLToFavourites(urlData: urlData);

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
            await updateURLToFavourites(urlData: urlData);
          },
        );
      },
    );
  }

  Future<void> deleteUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.deleting));

    final collection =
        _collectionsCubit.getCollection(collectionId: urlData.collectionId);

    await _urlRepoImpl
        .deleteUrlData(
      collection: collection!.collection!,
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
              collectionModel: collection.collection!,
            );

            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.deletedSuccessfully,
              ),
            );

            await deleteURLToFavourites(urlData: urlData);
          },
        );
      },
    );
  }

  Future<void> addURLToFavourites({
    required UrlModel urlData,
  }) async {
    final isFav = urlData.isFavourite;

    if (isFav == false) return;

    Logger.printLog('addingUrl: ${urlData.firestoreId}, to favourites');

    // CHECK IF FAVOURITES IS PRESENT IN STATE OR NOT
    final favouriteCollectionId =
        '${_globalUserCubit.getGlobalUser()!.id}$favourites';
    var favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    // IF NOT THEN FETCH IT FROM REPO AS ROOT COLLECTION (IMPTORTANT)
    // AND ADD TO THE COLLECTIONS
    if (favouriteCollection == null) {
      await _collectionsCubit.fetchCollection(
        collectionId: favouriteCollectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: true,
      );
    }
    // CHECK AGAIN IF NOT PRESENT THEN SOME ERROR OCCURED
    favouriteCollection = _collectionsCubit.getCollection(
      collectionId: favouriteCollectionId,
    );

    if (favouriteCollection == null) return;

    final favouriteURLsList = [
      urlData.firestoreId,
      ...favouriteCollection.collection!.urls,
    ];

    final updatedFavouriteCollection = favouriteCollection.collection!.copyWith(
      urls: favouriteURLsList,
    );

    await _collectionRepoImpl.updateSubCollection(
      subCollection: updatedFavouriteCollection,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    _collectionsCubit
      ..addUrl(
        url: urlData,
        collection: updatedFavouriteCollection,
      )
      ..updateCollection(
        updatedCollection: updatedFavouriteCollection,
        fetchSubCollIndexAdded: 0,
      );
  }

  Future<void> updateURLToFavourites({
    required UrlModel urlData,
  }) async {
    final isFav = urlData.isFavourite;

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

    final isUrlAlreadyPresentInList =
        favouriteCollection.collection!.urls.contains(
      urlData.firestoreId,
    );

    // Logger.printLog(
    //   '${urlData.firestoreId}, alp: $isCollectionAlreadyPresentInList, $isFav',
    // );

    if (isUrlAlreadyPresentInList && isFav == false) {
      await deleteURLToFavourites(urlData: urlData);
    } else if (isUrlAlreadyPresentInList == false && isFav) {
      await addURLToFavourites(urlData: urlData);
    }
  }

  Future<void> deleteURLToFavourites({
    required UrlModel urlData,
  }) async {
    final isFav = urlData.isFavourite;

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

    Logger.printLog('urlslist: ${favouriteCollection.collection!.urls}');
    final favouriteCollectionsList = [
      ...favouriteCollection.collection!.urls,
    ]..removeWhere(
        (element) => element == urlData.firestoreId,
      );

    Logger.printLog(
      'after removing ${urlData.firestoreId} urlslist: ${favouriteCollectionsList}',
    );

    final updatedFavouriteCollection = favouriteCollection.collection!.copyWith(
      urls: favouriteCollectionsList,
    );

    await _collectionRepoImpl.updateSubCollection(
      subCollection: updatedFavouriteCollection,
      userId: _globalUserCubit.getGlobalUser()!.id,
    );

    Logger.printLog('calling url for cubits collections deleteurl');
    _collectionsCubit
      ..deleteUrl(
        url: urlData,
        collectionModel: updatedFavouriteCollection,
      )
      ..updateCollection(
        updatedCollection: updatedFavouriteCollection,
        fetchSubCollIndexAdded: 0,
      );
  }
}
