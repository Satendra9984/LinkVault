// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/enums/collection_loading_states.dart';

part 'collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit({
    required CollectionsRepoImpl collectionsRepoImpl,
  })  : _collectionsRepoImpl = collectionsRepoImpl,
        super(
          const CollectionsState(
            collections: {},
            collectionUrls: {},
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
      return;
    }

    final fetchCollectionModel = CollectionFetchModel(
      collectionFetchingState: LoadingStates.loading,
      subCollectionFetchedIndex: -1,
    );

    final newCollection = {...state.collections};

    newCollection[collectionId] = fetchCollectionModel;

    emit(
      state.copyWith(
        collections: newCollection,
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
        final failedState = {...state.collections};
        final failedCollection = fetchCollectionModel.copyWith(
          collectionFetchingState: LoadingStates.errorLoading,
        );

        failedState[collectionId] = failedCollection;

        emit(
          state.copyWith(
            collections: failedState,
          ),
        );
      },
      (collection) {
        final loadedState = {...state.collections};
        final loadedCollection = fetchCollectionModel.copyWith(
          collectionFetchingState: LoadingStates.loaded,
          collection: collection,
        );

        loadedState[collectionId] = loadedCollection;

        emit(
          state.copyWith(
            collections: loadedState,
          ),
        );
      },
    );
  }

  Future<void> fetchMoreSubCollections({
    required String collectionId,
    required String userId,
    required bool isRootCollection,
    // required int start,
    required int end,
    required List<String> subCollectionIds,
  }) async {
    // assuming not collections in the state
    Logger.printLog(
      'FetchedMoreBefore: ${state.collections.keys.length}, ids: ${subCollectionIds}',
    );

    final moreCollections = <String, CollectionFetchModel>{};

    for (final subCollId in subCollectionIds) {
      final fetchCollectionModel = CollectionFetchModel(
        collectionFetchingState: LoadingStates.loading,
        subCollectionFetchedIndex: -1,
      );

      moreCollections[subCollId] = fetchCollectionModel;
    }

    final newCollection = {...state.collections, ...moreCollections};

    emit(
      state.copyWith(
        collections: newCollection,
      ),
    );

    /// NOW WILL FETCH AND UPDATE THE STATE AT ONCE FOR EACH SUBCOLLECTION
    final newFetchResultsState = {...state.collections};
    for (final subCollId in subCollectionIds) {
      final fetchCollectionModel = moreCollections[subCollId]!;

      final fetchedCollection = isRootCollection
          ? await _collectionsRepoImpl.fetchRootCollection(
              collectionId: subCollId,
              userId: userId,
            )
          : await _collectionsRepoImpl.fetchSubCollectionAsWhole(
              collectionId: subCollId,
            );

      // ignore: cascade_invocations
      fetchedCollection.fold(
        (failed) {
          // final failedState = {...state.collections};
          final failedCollection = fetchCollectionModel.copyWith(
            collectionFetchingState: LoadingStates.errorLoading,
          );

          newFetchResultsState[subCollId] = failedCollection;
        },
        (collection) {
          final loadedCollection = fetchCollectionModel.copyWith(
            collectionFetchingState: LoadingStates.loaded,
            collection: collection,
          );

          newFetchResultsState[subCollId] = loadedCollection;
        },
      );
    }

    emit(
      state.copyWith(
        collections: newFetchResultsState,
      ),
    );

    Logger.printLog('FetchedMoreAfter: ${state.collections.keys.length}');
  }

  CollectionFetchModel? getCollection({
    required String collectionId,
  }) {
    return state.collections[collectionId];
  }

  void addCollection({
    required CollectionModel collection,
  }) {
    // [TODO] : Add subcollection in db
    final fetchCollectionModel = CollectionFetchModel(
      collection: collection,
      collectionFetchingState: LoadingStates.loaded,
      subCollectionFetchedIndex: -1,
    );

    final newCollection = {...state.collections};

    newCollection[collection.id] = fetchCollectionModel;

    emit(
      state.copyWith(
        collections: newCollection,
      ),
    );
  }

  void deleteCollection({
    required CollectionModel collection,
  }) {
    // [TODO] : delete subcollection in db it will be cascade delete
    Logger.printLog(
      'collection before deletion ${state.collections.keys.length}',
    );
    final newCollMap = {...state.collections}..removeWhere(
        (key, value) => key == collection.id,
      );

    emit(
      state.copyWith(
        collections: newCollMap,
      ),
    );
    Logger.printLog(
      'collection after  deletion ${state.collections.keys.length}',
    );
  }

  void updateCollection({
    required CollectionModel updatedCollection,
    required int fetchSubCollIndexAdded,
  }) {
    final prevCollection = state.collections[updatedCollection.id]!;

    Logger.printLog(
      'updatecollection: ${StringUtils.getJsonFormat(updatedCollection.toJson())}',
    );

    final updatedCollectionfetch = prevCollection.copyWith(
      collection: updatedCollection,
      subCollectionFetchedIndex:
          prevCollection.subCollectionFetchedIndex + fetchSubCollIndexAdded,
    );

    final newState = {...state.collections};
    newState[updatedCollection.id] = updatedCollectionfetch;

    emit(
      state.copyWith(
        collections: newState,
      ),
    );

    Logger.printLog(
      'updatecollectionafter: ${StringUtils.getJsonFormat(prevCollection.collection?.toJson())}',
    );
  }

  // <--------------------------- URLS --------------------------------->

  Future<void> fetchMoreUrls({
    required String collectionId,
    required String userId,
    // required int start,
    required int end,
    required List<String> urlIds,
  }) async {
    final moreUrls = <UrlFetchStateModel>[];

    for (final _ in urlIds) {
      final urlFetchModel = UrlFetchStateModel(
        collectionId: collectionId,
        loadingStates: LoadingStates.loading,
      );

      moreUrls.add(urlFetchModel);
    }

    final currentUrlsState = state.collectionUrls[collectionId]!;
    final newUrls = [...currentUrlsState, ...moreUrls];
    final updatedUrlsState = {...state.collectionUrls};
    updatedUrlsState[collectionId] = newUrls;
    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );

    final fetchedUrlsWithData = <UrlFetchStateModel>[];
    for (final urlId in urlIds) {
      final fetchedUrl = await _collectionsRepoImpl.fetchUrl(urlId: urlId);

      // ignore: cascade_invocations
      fetchedUrl.fold(
        (failed) {
          final urlFetchModel = UrlFetchStateModel(
            collectionId: collectionId,
            loadingStates: LoadingStates.errorLoading,
          );

          fetchedUrlsWithData.add(urlFetchModel);
        },
        (url) {
          final urlFetchModel = UrlFetchStateModel(
            collectionId: collectionId,
            loadingStates: LoadingStates.loaded,
            urlModel: url,
          );

          fetchedUrlsWithData.add(urlFetchModel);
        },
      );
    }

    final fetchedUrls = [...newUrls];

    fetchedUrls.replaceRange(
      fetchedUrls.length - urlIds.length,
      end,
      fetchedUrlsWithData,
    );

    final updatedFetchedUrlsState = {...state.collectionUrls};
    updatedFetchedUrlsState[collectionId] = fetchedUrls;
    emit(
      state.copyWith(
        collectionUrls: updatedFetchedUrlsState,
      ),
    );
  }

  void addUrl({
    required UrlModel url,
    required CollectionModel collection,
  }) {
    final fetchedUrl = UrlFetchStateModel(
      collectionId: collection.id,
      loadingStates: LoadingStates.loaded,
      urlModel: url,
    );

    final updatedUrlsState = {...state.collectionUrls};

    final updatedUrlsList = [
      fetchedUrl,
      ...updatedUrlsState[url.collectionId]!,
    ];

    updatedUrlsState[url.collectionId] = updatedUrlsList;

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }

  void updateUrl({required UrlModel url}) {
    final fetchedUrlList = state.collectionUrls[url.collectionId];

    if (fetchedUrlList == null) {
      return;
    }

    final index = fetchedUrlList.indexWhere(
      (element) {
        if (element.urlModel != null && element.urlModel!.id == url.id) {
          return true;
        }
        return false;
      },
    );

    final updatedList = [...fetchedUrlList];

    if (index != -1) {
      updatedList[index] = updatedList[index].copyWith(
        urlModel: url,
      );
    }

    final updatedUrlsState = {...state.collectionUrls};

    updatedUrlsState[url.collectionId] = updatedList;

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }

  void deleteUrl({
    required UrlModel url,
    required CollectionModel? collectionModel,
  }) {
    final fetchedUrlList = state.collectionUrls[url.collectionId];

    if (fetchedUrlList == null) {
      return;
    }

    final updatedList = [...fetchedUrlList]..removeWhere(
        (element) {
          if (element.urlModel != null && element.urlModel!.id == url.id) {
            return true;
          }
          return false;
        },
      );

    final updatedUrlsState = {...state.collectionUrls};

    updatedUrlsState[url.collectionId] = updatedList;

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }
}
