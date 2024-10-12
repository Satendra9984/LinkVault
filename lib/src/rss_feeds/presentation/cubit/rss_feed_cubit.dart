import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/app_home/services/custom_image_cache_manager.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/rss_feeds/data/constants/rss_feed_constants.dart';
import 'package:link_vault/src/rss_feeds/data/repositories/rss_feed_repo.dart';

part 'rss_feed_state.dart';

class RssFeedCubit extends Cubit<RssFeedState> {
  RssFeedCubit({
    required CollectionsCubit collectionCubit,
    required CollectionCrudCubit collectionCrudCubit,
    required GlobalUserCubit globalUserCubit,
  })  : _collectionCubit = collectionCubit,
        _collectionCrudCubit = collectionCrudCubit,
        _globalUserCubit = globalUserCubit,
        super(
          const RssFeedState(
            feedCollections: {},
          ),
        );

  final CollectionsCubit _collectionCubit;
  final CollectionCrudCubit _collectionCrudCubit;
  final GlobalUserCubit _globalUserCubit; // Add this line
  final RssFeedRepo _rssFeedRepo = RssFeedRepo();

  void initializeNewFeed({
    required String collectionId,
  }) {
    if (state.feedCollections.containsKey(collectionId)) {
      return;
    }

    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: RssFeedModel.initial(),
        },
      ),
    );

    final collectionFetchModel =
        _collectionCubit.getCollection(collectionId: collectionId)!;
    final callTimes = collectionFetchModel.collection!.urls.length ~/ 23;

    for (var i = 0; i <= callTimes; i++) {
      final fetchCollection = collectionFetchModel;
      _collectionCubit.fetchMoreUrls(
        collectionId: fetchCollection.collection!.id,
        userId: _globalUserCubit.state.globalUser!.id,
      );
    }

    CustomImagesCacheManager.instance.initCacheManager(
      cacheKey: collectionId,
      stalePeriod: const Duration(hours: rssFeedStalePeriodHours),
      maxNrOfCacheObjects: maxNrOfCacheObjects,
    );
  }

  void clearCollectionFeed({
    required String collectionId,
  }) {
    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: RssFeedModel.initial(),
        },
      ),
    );
  }

  Future<void> refreshCollectionFeed({
    required String collectionId,
  }) async {
    final collection =
        _collectionCubit.getCollection(collectionId: collectionId)?.collection;

    if (collection == null) return;

    for (final urlId in collection.urls) {
      await _rssFeedRepo.deleteAllFeeds(firestoreId: urlId);
    }

    clearCollectionFeed(collectionId: collectionId);
    getAllRssFeedofCollection(collectionId: collectionId);
  }

  Future<void> getAllRssFeedofCollection({
    required String collectionId,
  }) async {
    // Get The Collection from CollectionCubit
    final currentCollection =
        _collectionCubit.getCollection(collectionId: collectionId)!;

    final currentFeedState = state.feedCollections[collectionId];

    if (currentFeedState != null &&
        (currentFeedState.loadingMoreStates == LoadingStates.errorLoading ||
            currentFeedState.loadingMoreStates == LoadingStates.loading)) {
      return;
    }

    // Check when last fetched
    final lastUpdateDate = currentCollection.collection!.updatedAt;
    if (lastUpdateDate.hour > 8) {
      await Future.wait([
        // 1. Delete all feeds
        _rssFeedRepo.deleteAllFeeds(
          firestoreId: currentCollection.collection!.id,
        ),

        // 2. Emit the new state
        Future(() {
          emit(
            state.copyWith(
              feedCollections: {
                ...state.feedCollections,
                collectionId: RssFeedModel.initial(),
              },
            ),
          );
        }),

        // 3. Update collection with new updatedAt
        Future(() async {
          final updatedat = currentCollection.collection!.copyWith(
            updatedAt: DateTime.now().toUtc(),
          );

          await _collectionCrudCubit.updateCollection(collection: updatedat);
        }),

        // 4. delete all images for this collection
        // Future(() async {
        //   await CustomImagesCacheManager.instance
        //       .clearCacheForCollection(collectionId);
        // }),
      ]);
    }

    fetchAllRssFeed(collectionId: collectionId);
  }

  Future<void> fetchAllRssFeed({
    required String collectionId,
  }) async {
    // Fetch all the URLs for the given collection
    final fetchedUrls =
        _collectionCubit.urlsFetchModelList(collectionId: collectionId) ?? [];

    // Extract UrlModels from the fetched URLs
    final urlModelList = <UrlModel>[];
    for (final urlModel in fetchedUrls) {
      if (urlModel.urlModel != null) {
        urlModelList.add(urlModel.urlModel!);
      }
    }

    // Emit a loading state
    final currentCollectionFeed = state.feedCollections[collectionId]!.copyWith(
      loadingMoreStates: LoadingStates.loading,
    );

    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: currentCollectionFeed,
        },
      ),
    );

    final allFeeds = <UrlModel>[]; // List to collect all feeds
    final completer = Completer<void>(); // Completer to track completion
    final futures = <Future<void>>[]; // Future list to await all feed fetches

    for (final urlModel in urlModelList) {
      // Create a future that resolves when the feed fetching for each URL is done
      final future = Future(
        () {
          return _rssFeedRepo.getAllFeeds(urlModels: [urlModel]).listen(
            (result) {
              result.fold(
                (failure) {
                  // Handle failure if necessary (optional)
                  Logger.printLog(
                    'Failed to fetch feeds for URL: ${urlModel.url}',
                  );
                },
                allFeeds.addAll,
              );
            },
            onDone: () {
              // Logger.printLog('Done fetching feeds for URL: ${urlModel.url}');
              if (urlModel == urlModelList.last) {
                completer
                    .complete(); // Complete the completer when the last URL is done
              }
            },
            onError: (Object error) {
              // Logger.printLog('An error occurred while fetching feeds: $error');
              completer
                  .completeError(error); // Complete the completer with an error
            },
          );
        },
      );

      futures.add(future);
    }

    // Wait for all streams to complete
    await completer.future.then(
      (value) {
        allFeeds.sort(
          (u1, u2) => u2.createdAt.compareTo(u1.createdAt),
        );
        // Update the state with all feeds after all fetching is done
        final updatedCollectionFeed =
            state.feedCollections[collectionId]!.copyWith(
          allFeeds: allFeeds,
          loadingStates: LoadingStates.loaded,
        );

        emit(
          state.copyWith(
            feedCollections: {
              ...state.feedCollections,
              collectionId: updatedCollectionFeed,
            },
          ),
        );
      },
    );
  }

  List<UrlModel> getMoreUrls({
    required String collectionId,
    required int currentIndex,
  }) {
    final moreFeeds = <UrlModel>[];
    if (state.feedCollections.containsKey(collectionId) == false) {
      return moreFeeds;
    }

    final feedsInstate = state.feedCollections[collectionId]!.allFeeds;

    final lastIndex = min(feedsInstate.length, currentIndex + 15);

    moreFeeds.addAll(feedsInstate.sublist(currentIndex + 1, lastIndex));

    return moreFeeds;
  }

  RssFeedModel? getFeedsOfCollection(String collectionId) {
    return state.feedCollections[collectionId];
  }

  Future<UrlModel> updateBannerImagefromRssFeedUrl({
    required UrlModel urlModel,
    required int index,
  }) async {
    final rssFeedUrl = urlModel.metaData?.rssFeedUrl;

    if (rssFeedUrl == null) return urlModel;

    if (urlModel.metaData!.bannerImageUrl != null) {
      return urlModel;
    }
    try {
      // Logger.printLog(
      //   '[rss] : updatingurlmodelrssimage ${StringUtils.getJsonFormat(urlModel.metaData?.toJson())}',
      // );

      final updatedUrlModel =
          await _rssFeedRepo.updateBannerImagefromRssFeedUrl(
        urlModel: urlModel,
      );

      // Logger.printLog(
      //   '[rss] : updatingurlmodelrssimageafter ${StringUtils.getJsonFormat(updatedUrlModel.metaData?.toJson())}',
      // );
      // UPDATE THE STATE WITHOUT EMITTING
      // final feeds = state.feedCollections[urlModel.collectionId];

      // if (feeds == null) return updatedUrlModel;

      // final allfeeds = feeds.allFeeds;
      // allfeeds[index] = updatedUrlModel;

      // state.feedCollections[urlModel.collectionId] =
      //     feeds.copyWith(allFeeds: allfeeds);

      return updatedUrlModel;
    } catch (e) {
      return urlModel;
    }
  }
}
