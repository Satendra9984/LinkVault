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
            // collectionUrls: {},
            // currentCollection: '',
            // collectionLoadingStates: CollectionLoadingStates.initial,
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
      urlFetchMoreState: LoadingStates.initial,
      urlList: const [],
    );

    final newCollection = {...state.collections};

    newCollection[collectionId] = ValueNotifier(fetchCollectionModel);

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
        state.collections[collectionId]!.value =
            state.collections[collectionId]!.value.copyWith(
          subCollectionsFetchingState: LoadingStates.errorLoading,
        );
      },
      (collection) {
        state.collections[collectionId]!.value =
            state.collections[collectionId]!.value.copyWith(
          subCollectionsFetchingState: LoadingStates.loaded,
          collection: collection,
        );

        // Logger.printLog(
        //   'Fetched: ${StringUtils.getJsonFormat(collection.toJson())}',
        // );
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

    final moreCollections = <String, ValueNotifier<CollectionFetchModel>>{};

    for (final subCollId in subCollectionIds) {
      final fetchCollectionModel = CollectionFetchModel(
        collectionFetchingState: LoadingStates.loading,
        subCollectionFetchedIndex: -1,
        urlFetchMoreState: LoadingStates.initial,
        urlList: const [],
      );

      moreCollections[subCollId] = ValueNotifier(fetchCollectionModel);
    }

    final newCollection = {...state.collections, ...moreCollections};

    emit(
      state.copyWith(
        collections: newCollection,
      ),
    );

    for (final subCollId in subCollectionIds) {
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
          state.collections[subCollId]!.value =
              state.collections[subCollId]!.value.copyWith(
            subCollectionsFetchingState: LoadingStates.errorLoading,
          );
        },
        (collection) {
          state.collections[subCollId]!.value =
              state.collections[subCollId]!.value.copyWith(
            subCollectionsFetchingState: LoadingStates.loaded,
            collection: collection,
          );
        },
      );
    }

    state.collections[collectionId]!.value =
        state.collections[collectionId]!.value.copyWith(
      subCollectionFetchedIndex: end,
    );

    Logger.printLog('FetchedMoreAfter: ${state.collections.keys.length}');
  }

  CollectionFetchModel? getCollection({
    required String collectionId,
  }) {
    return state.collections[collectionId]?.value;
  }

  void addCollection({
    required CollectionModel collection,
  }) {
    // [TODO] : Add subcollection in db
    final fetchCollectionModel = CollectionFetchModel(
      collectionFetchingState: LoadingStates.loading,
      subCollectionFetchedIndex: -1,
      urlFetchMoreState: LoadingStates.initial,
      urlList: const [],
    );

    final newCollection = {...state.collections};

    newCollection[collection.id] = ValueNotifier(fetchCollectionModel);

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
  }) {
    final newCollMap = {...state.collections};

    final fetchCollectionModel =
        newCollMap[updatedCollection.id]!.value.copyWith(
              collection: updatedCollection,
            );

    final newCollection = {...state.collections};

    newCollection[updatedCollection.id] = ValueNotifier(fetchCollectionModel);

    emit(
      state.copyWith(
        collections: newCollection,
      ),
    );
  }

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

    final fetchCollection = state.collections[collectionId]!;

    final newUrls = [...fetchCollection.value.urlList, ...moreUrls];

    fetchCollection.value = fetchCollection.value.copyWith(
      urlList: newUrls,
      urlFetchMoreState: LoadingStates.loading,
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

    final fetchedUrls = [...fetchCollection.value.urlList];

    fetchedUrls.replaceRange(
      fetchedUrls.length - urlIds.length,
      end,
      fetchedUrlsWithData,
    );

    fetchCollection.value = fetchCollection.value.copyWith(
      urlList: fetchedUrls,
      urlFetchMoreState: LoadingStates.loaded,
    );
  }

  void addUrl({
    required UrlModel url,
    required CollectionModel collection,
  }) {
    final fetchedCollection = state.collections[collection.id]!;

    final fetchedUrl = UrlFetchStateModel(
      collectionId: collection.id,
      loadingStates: LoadingStates.loaded,
      urlModel: url,
    );

    final fetchedUrlList = [fetchedUrl, ...fetchedCollection.value.urlList];

    fetchedCollection.value = fetchedCollection.value.copyWith(
      collection: collection,
      urlList: fetchedUrlList,
    );
  }

  void updateUrl({
    required UrlModel url,
  }) {
    // final urlMap = {...state.collectionUrls};
    // urlMap[url.id] = url;

    // emit(
    //   state.copyWith(
    //     collectionUrls: urlMap,
    //   ),
    // );
  }

  void deleteUrl({
    required UrlModel url,
    required CollectionModel? collection,
  }) {
    // final urlMap = {...state.collectionUrls}..remove(url.id);

    // if (collection != null) {
    //   updateCollection(updatedCollection: collection);
    // }

    // emit(
    //   state.copyWith(
    //     collectionUrls: urlMap,
    //   ),
    // );
  }
}
