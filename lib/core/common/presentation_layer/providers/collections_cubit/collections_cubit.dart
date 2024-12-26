// ignore_for_file: public_member_api_docs
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_filters_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';
import 'package:link_vault/core/utils/queue_manager.dart';

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

  // FETCH THE SINGLE COLLECTION
  // MAINLY FOR STORE-PAGE
  Future<void> fetchCollection({
    required String prentCollectionId,
    required String userId,
    required bool isRootCollection,
    String? collectionName,
  }) async {
    if (state.collections.containsKey(prentCollectionId)) {
      final fetch = state.collections[prentCollectionId]!;

      if (fetch.collectionFetchingState == LoadingStates.loading ||
          fetch.collectionFetchingState == LoadingStates.loaded) {
        return;
      }

      const fetchCollectionModel = CollectionFetchModel(
        collectionFetchingState: LoadingStates.loading,
      );

      final newCollection = {...state.collections};

      newCollection[prentCollectionId] = fetchCollectionModel;

      emit(
        state.copyWith(
          collections: newCollection,
        ),
      );

      final fetchedCollection = isRootCollection
          ? await _collectionsRepoImpl.fetchRootCollection(
              collectionId: prentCollectionId,
              userId: userId,
              collectionName: collectionName,
            )
          : await _collectionsRepoImpl.fetchSubCollection(
              collectionId: prentCollectionId,
              userId: _globalUserCubit.state.globalUser!.id,
            );

      // ignore: cascade_invocations
      fetchedCollection.fold(
        (failed) {
          final failedState = {...state.collections};
          final failedCollection = fetchCollectionModel.copyWith(
            collectionFetchingState: LoadingStates.errorLoading,
          );

          failedState[prentCollectionId] = failedCollection;

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

          loadedState[prentCollectionId] = loadedCollection;

          emit(
            state.copyWith(
              collections: loadedState,
            ),
          );
        },
      );
    }
  }

  // FETCH THE SUBCOLLECTION FROM THE DATABASE
  // IT ADDS THE QUERY IN THE QUEUE
  Future<void> fetchMoreSubCollections({
    required String collectionId,
    required String userId,
    required bool isRootCollection,
    // FILTERS
    required bool isAtoZFilter,
    required bool isLatestFirst,
  }) async {
    _collQueueManager.addTask(
      () => _fetchMoreSubCollections(
        parentCollectionId: collectionId,
        userId: userId,
        isAtoZFilter: isAtoZFilter,
        isLatestFirst: isLatestFirst,
      ),
    );
  }

  Future<void> _fetchMoreSubCollections({
    required String parentCollectionId,
    required String userId,
    // FILTERS
    required bool? isAtoZFilter,
    required bool? isLatestFirst,
  }) async {
    final fetchedCollection = state.collections[parentCollectionId];

    if (fetchedCollection == null) return;

    final currentList =
        getSubCollectionList(parentCollectionId: parentCollectionId);

    if (currentList == null) return;

    final filter = CollectionFilter(
      parentCollection: fetchedCollection.collection!.parentCollection,
      sortByDateAsc: isLatestFirst,
      sortByNameAsc: isAtoZFilter,
      limit: 16,
      offset: currentList.length - 1,
    );

    await _collectionsRepoImpl
        .fetchSubCollectionsListByFilter(
      filter: filter,
      userId: userId,
    )
        .then(
      (data) {
        data.fold(
          (failure) {},
          (list) {
            final nextCollectionBatch = <String, CollectionFetchModel>{};

            for (final collectionModel in list) {
              nextCollectionBatch[collectionModel.id] = CollectionFetchModel(
                collectionFetchingState: LoadingStates.loaded,
                collection: collectionModel,
              );
            }

            emit(
              state.copyWith(
                collections: {
                  ...state.collections,
                  ...nextCollectionBatch,
                },
              ),
            );
          },
        );
      },
    );
  }

  // GETTING COLLECTIONS LIST FROM THE
  // PARENT COLLECTION-ID
  List<CollectionFetchModel>? getSubCollectionList({
    required String parentCollectionId,
  }) {
    final collections = <CollectionFetchModel>[];

    for (final entry in state.collections.entries) {
      if (entry.value.collection == null) {
        continue;
      }

      if (entry.value.collection!.parentCollection == parentCollectionId) {
        collections.add(entry.value);
      }
    }

    return collections;
  }

  // GET A SINGLE COLLECTION
  CollectionFetchModel? getCollection({
    required String collectionId,
  }) {
    return state.collections[collectionId];
  }

  // ADD THE COLLECTION IN THE STATE
  void addSubCollectionInState({
    required CollectionModel collection,
  }) {
    // Add subcollection in db
    final fetchCollectionModel = CollectionFetchModel(
      collection: collection,
      collectionFetchingState: LoadingStates.loaded,
    );

    final newCollection = {...state.collections};

    newCollection[collection.id] = fetchCollectionModel;

    final newCollectionUrls = {...state.collectionUrls};

    emit(
      state.copyWith(
        collections: newCollection,
        collectionUrls: newCollectionUrls,
      ),
    );
  }

  // DELETE THE COLLECTION IN THE STATE
  void deleteCollectionInState({
    required CollectionModel collection,
  }) {
    final newCollMap = {...state.collections}..removeWhere(
        (key, value) => key == collection.id,
      );

    final newCollUrlsMap = {...state.collectionUrls}..removeWhere(
        (key, value) => key == collection.id,
      );

    emit(
      state.copyWith(
        collections: newCollMap,
        collectionUrls: newCollUrlsMap,
      ),
    );
  }

  // UPDATE THE COLLECTION IN THE STATE
  void updateCollectionInState({
    required CollectionModel updatedCollection,
    LoadingStates? collectionFetchState,
  }) {
    final prevCollection = state.collections[updatedCollection.id];
    if (prevCollection == null) return;

    final updatedCollectionfetch = prevCollection.copyWith(
      collection: updatedCollection,
      collectionFetchingState: collectionFetchState,
    );

    final newCollectionsState = {
      ...state.collections,
    };
    newCollectionsState[updatedCollection.id] = updatedCollectionfetch;

    emit(
      state.copyWith(
        collections: newCollectionsState,
      ),
    );
  }

  // <--------------------------------- URLS ---------------------------------->

  Future<UrlModel?> fetchUrlModel(String urlModelId) async {
    UrlModel? fetchedUrlModel;

    await _collectionsRepoImpl
        .fetchUrl(
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

  Future<void> fetchMoreUrls({
    required String collectionId,
    required String userId,
    // FILTERS
    required bool isAtoZFilter,
    required bool isLatestFirst,
  }) async {
    _urlQueueManager.addTask(
      () => _fetchMoreUrls(
        collectionId: collectionId,
        userId: userId,
        isAtoZFilter: isAtoZFilter,
        isLatestFirst: isLatestFirst,
      ),
    );
  }

  Future<void> _fetchMoreUrls({
    required String collectionId,
    required String userId,
    // FILTERS
    required bool? isAtoZFilter,
    required bool? isLatestFirst,
  }) async {
    final fetchCollection = state.collections[collectionId];

    if (fetchCollection == null ||
        fetchCollection.collectionFetchingState == LoadingStates.loading ||
        fetchCollection.collection == null) {
      return;
    }

    // TODO : MAKE URL FETCHING WITH NEW APPROACH
    final currentCollectionUrls =
        getUrlsList(collectionId: collectionId) ?? <UrlFetchStateModel>[];

    final filter = UrlModelFilters(
      collectionId: collectionId,
      sortByDateAsc: isLatestFirst,
      sortByNameAsc: isAtoZFilter,
      limit: 16,
      offset:
          currentCollectionUrls.isEmpty ? 0 : currentCollectionUrls.length - 1,
    );

    //
  }

  List<UrlFetchStateModel>? getUrlsList({
    required String collectionId,
  }) {
    final collections = <UrlFetchStateModel>[];

    for (final entry in state.collectionUrls.entries) {
      if (entry.value.urlModel == null) continue;

      if (entry.value.collectionId == collectionId) {
        collections.add(entry.value);
      }
    }

    return collections;
  }

  void addUrlInState({
    required UrlFetchStateModel url,
  }) {
    final updatedUrlsState = {
      ...state.collectionUrls,
      url.urlModel!.firestoreId: url,
    };

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }

  void updateUrlInState({
    required UrlFetchStateModel url,
  }) {
    final updatedUrlsState = {
      ...state.collectionUrls,
      url.urlModel!.firestoreId: url,
    };

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }

  void deleteUrlInState({
    required UrlModel url,
  }) {
    final updatedUrlsState = {...state.collectionUrls}..removeWhere(
        (key, value) => key == url.firestoreId,
      );

    emit(
      state.copyWith(
        collectionUrls: updatedUrlsState,
      ),
    );
  }
}
