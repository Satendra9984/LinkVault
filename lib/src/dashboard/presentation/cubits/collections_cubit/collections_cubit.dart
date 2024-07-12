// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
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
            currentCollection: '',
            collectionLoadingStates: CollectionLoadingStates.initial,
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
      var containsAllSubColl = true;
      final coll = state.collections[collectionId]!;
      for (final subcId in coll.subcollections) {
        if (state.collections.containsKey(subcId) == false) {
          containsAllSubColl = false;
          break;
        }
      }

      if (containsAllSubColl) {
        return;
      }
    }

    emit(
      state.copyWith(
        currentCollection: collectionId,
        collectionLoadingStates: CollectionLoadingStates.fetching,
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
        emit(
          state.copyWith(
            currentCollection: collectionId,
            collectionLoadingStates: CollectionLoadingStates.errorLoading,
          ),
        );
      },
      (tuple) {
        final (collection, subCollectionsMap, urlList) = tuple;

        // Adding Collection
        final newCollMap = {...state.collections};
        newCollMap[collectionId] = collection;
        // Adding all its subcollections
        newCollMap.addAll(subCollectionsMap);
        // Adding all the urls
        final newUrlsMap = {...state.collectionUrls};
        for (final url in urlList) {
          newUrlsMap[url.id] = url;
        }
        // updating the state
        emit(
          state.copyWith(
            currentCollection: collectionId,
            collections: newCollMap,
            collectionUrls: newUrlsMap,
            collectionLoadingStates: CollectionLoadingStates.successLoading,
          ),
        );
      },
    );
  }

  CollectionModel? getCollection({
    required String collectionId,
  }) {
    return state.collections[collectionId];
  }

  void addCollection({
    required CollectionModel collection,
  })  {
    // [TODO] : Add subcollection in db

    final newCollMap = {...state.collections};
    newCollMap[collection.id] = collection;

    emit(
      state.copyWith(
        collections: newCollMap,
      ),
    );
  }

  void deleteCollection({
    required CollectionModel subcollection,
  })  {
    // [TODO] : delete subcollection in db it will be cascade delete
  }

  void updateCollection({
    required CollectionModel updatedCollection,
  }) {
    final newCollMap = {...state.collections};
    newCollMap[updatedCollection.id] = updatedCollection;

    emit(
      state.copyWith(
        currentCollection: updatedCollection.parentCollection,
        collections: newCollMap,
      ),
    );
  }

  void addUrl({
    required UrlModel url,
    required CollectionModel collection,
  }) {
    final urlMap = {...state.collectionUrls};
    urlMap[url.id] = url;
    updateCollection(updatedCollection: collection);

    emit(
      state.copyWith(
        collectionUrls: urlMap,
      ),
    );
  }

  void updateUrl({
    required UrlModel url,
  }) {
    final urlMap = {...state.collectionUrls};
    urlMap[url.id] = url;

    emit(
      state.copyWith(
        collectionUrls: urlMap,
      ),
    );
  }

  void deleteUrl({
    required UrlModel url,
    required CollectionModel? collection,
  }) {
    final urlMap = {...state.collectionUrls}..remove(url.id);

    if (collection != null) {
      updateCollection(updatedCollection: collection);
    }

    emit(
      state.copyWith(
        collectionUrls: urlMap,
      ),
    );
  }
}
