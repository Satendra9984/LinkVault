// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/services/queue_manager.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';

part 'collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit({
    required CollectionsRepoImpl collectionsRepoImpl,
    required GlobalUserCubit globalUserCubit,
  })  : _collectionsRepoImpl = collectionsRepoImpl,
        _globalUserCubit = globalUserCubit,
        super(
          const CollectionsState(
            collections: {},
            collectionUrls: {},
          ),
        );

  final GlobalUserCubit _globalUserCubit;
  final CollectionsRepoImpl _collectionsRepoImpl;

  final AsyncQueueManager _collQueueManager = AsyncQueueManager();
  final AsyncQueueManager _urlQueueManager = AsyncQueueManager();

  Future<void> fetchCollection({
    required String collectionId,
    required String userId,
    required bool isRootCollection,
    String? collectionName,
  }) async {
    if (state.collections.containsKey(collectionId)) {
      final fetch = state.collections[collectionId]!;

      if (fetch.collectionFetchingState == LoadingStates.loaded ||
          fetch.collectionFetchingState == LoadingStates.loading) {
        return;
      }
    }

    const fetchCollectionModel = CollectionFetchModel(
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
            collectionName: collectionName,
          )
        : await _collectionsRepoImpl.fetchSubCollection(
            collectionId: collectionId,
            userId: _globalUserCubit.state.globalUser!.id,
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
  }) async {
    _collQueueManager.addTask(
      () => _fetchMoreSubCollections(
        collectionId: collectionId,
        userId: userId,
        isRootCollection: isRootCollection,
      ),
    );
  }

  Future<void> _fetchMoreSubCollections({
    required String collectionId,
    required String userId,
    required bool isRootCollection,
  }) async {
    // Assuming Not Collections In The State
    final fetchedCollection = state.collections[collectionId];

    if (fetchedCollection == null ||
        fetchedCollection.collectionFetchingState == LoadingStates.loading ||
        fetchedCollection.collection == null) {
      return;
    }

    final subCollections = fetchedCollection.collection!.subcollections;

    if (fetchedCollection.subCollectionFetchedIndex >=
        subCollections.length - 1) {
      return;
    }

    final start = fetchedCollection.subCollectionFetchedIndex + 1;

    final end = min(subCollections.length, start + 16);

    final moreSubcollectionIds = [...subCollections.sublist(start, end)];

    // Logger.printLog(
    //   'FetchedMoreBefore: ${state.collections.keys.length}, ids: $moreSubcollectionIds',
    // );

    final moreCollections = <String, CollectionFetchModel>{};
    for (final subCollId in moreSubcollectionIds) {
      const fetchCollectionModel = CollectionFetchModel(
        collectionFetchingState: LoadingStates.loading,
        subCollectionFetchedIndex: -1,
      );

      moreCollections[subCollId] = fetchCollectionModel;
    }

    final newCollection = {...state.collections, ...moreCollections};
    newCollection[collectionId] = fetchedCollection.copyWith(
      subCollectionFetchedIndex: end - 1,
    );

    emit(
      state.copyWith(
        collections: newCollection,
      ),
    );

    /// NOW WILL FETCH AND UPDATE THE STATE AT ONCE FOR EACH SUBCOLLECTION
    final newFetchResultsState = {...state.collections};
    for (final subCollId in moreSubcollectionIds) {
      final fetchCollectionModel = moreCollections[subCollId]!;

      final fetchedCollection = isRootCollection
          ? await _collectionsRepoImpl.fetchRootCollection(
              collectionId: subCollId,
              userId: userId,
            )
          : await _collectionsRepoImpl.fetchSubCollection(
              collectionId: subCollId,
              userId: _globalUserCubit.state.globalUser!.id,
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

    // Logger.printLog('FetchedMoreAfter: ${state.collections.keys.length}');
  }

  CollectionFetchModel? getCollection({
    required String collectionId,
  }) {
    return state.collections[collectionId];
  }

  void addCollection({
    required CollectionModel collection,
  }) {
    // Add subcollection in db
    final fetchCollectionModel = CollectionFetchModel(
      collection: collection,
      collectionFetchingState: LoadingStates.loaded,
      subCollectionFetchedIndex: -1,
    );

    final newCollection = {...state.collections};

    newCollection[collection.id] = fetchCollectionModel;

    final newCollectionUrls = {...state.collectionUrls};

    newCollectionUrls[collection.id] = [];

    emit(
      state.copyWith(
        collections: newCollection,
        collectionUrls: newCollectionUrls,
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
  }

  // <--------------------------------- URLS ---------------------------------->

  Future<void> fetchMoreUrls({
    required String collectionId,
    required String userId,
  }) async {
    _urlQueueManager.addTask(
      () => _fetchMoreUrls(
        collectionId: collectionId,
        userId: userId,
      ),
    );
  }

  Future<void> _fetchMoreUrls({
    required String collectionId,
    required String userId,
  }) async {
    final fetchCollection = state.collections[collectionId];

    if (fetchCollection == null ||
        fetchCollection.collectionFetchingState == LoadingStates.loading ||
        fetchCollection.collection == null) {
      return;
    }

    final urlsList = fetchCollection.collection!.urls;
    final alreadyFetchedUrls = [
      ...state.collectionUrls[collectionId] ?? <UrlFetchStateModel>[],
    ];

    if (alreadyFetchedUrls.length >= urlsList.length) {
      return;
    }

    final start = alreadyFetchedUrls.length;
    final end = min(urlsList.length, start + 20);

    final urlIds = urlsList.sublist(start, end);

    final moreUrls = <UrlFetchStateModel>[];
    for (final _ in urlIds) {
      final urlFetchModel = UrlFetchStateModel(
        collectionId: collectionId,
        loadingStates: LoadingStates.loading,
      );

      moreUrls.add(urlFetchModel);
    }

    final newUrls = [...alreadyFetchedUrls, ...moreUrls];
    final updatedUrlsState = {...state.collectionUrls};
    updatedUrlsState[collectionId] = newUrls;
    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );

    final fetchedUrlsWithData = <UrlFetchStateModel>[];
    for (final urlId in urlIds) {
      final fetchedUrl = await _collectionsRepoImpl.fetchUrl(
        urlId: urlId,
        userId: _globalUserCubit.state.globalUser!.id,
      );

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

    final urlCollection = state.collectionUrls[collection.id];

    if (urlCollection == null) {
      addCollection(collection: collection);
    }

    final updatedUrlsState = {...state.collectionUrls};
    // [TODO] : [important] changed url.collectionId to collection.id
    final updatedUrlsList = [
      fetchedUrl,
      ...updatedUrlsState[collection.id]!,
    ];

    updatedUrlsState[collection.id] = updatedUrlsList;

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
        if (element.urlModel != null &&
            element.urlModel!.firestoreId == url.firestoreId) {
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
    required CollectionModel collectionModel,
  }) {
    Logger.printLog(
      'deleting in state: ${url.collectionId}, ',
    );
    final fetchedUrlList = state.collectionUrls[collectionModel.id];

    if (fetchedUrlList == null) {
      return;
    }

    Logger.printLog(
      'deleting in state: ${url.collectionId}, ${fetchedUrlList}',
    );

    final updatedList = [...fetchedUrlList]..removeWhere(
        (element) {
          if (element.urlModel != null &&
              element.urlModel!.firestoreId == url.firestoreId) {
            return true;
          }
          return false;
        },
      );

    final updatedUrlsState = {...state.collectionUrls};
    Logger.printLog('deleting in state: ${collectionModel.id}, ${updatedList}');

    updatedUrlsState[collectionModel.id] = updatedList;

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }

}
