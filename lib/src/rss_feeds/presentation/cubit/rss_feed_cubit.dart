import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/url_repo_impl.dart';
import 'package:link_vault/core/services/custom_image_cache_service.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/rss_feeds/data/constants/rss_feed_constants.dart';
import 'package:link_vault/src/rss_feeds/data/repositories/rss_feed_repo.dart';

part 'rss_feed_state.dart';

class RssFeedCubit extends Cubit<RssFeedState> {
  RssFeedCubit({
    required CollectionsCubit collectionCubit,
    required CollectionCrudCubit collectionCrudCubit,
    required GlobalUserCubit globalUserCubit,
    required UrlRepoImpl urlRepoImpl,
  })  : _collectionCubit = collectionCubit,
        _collectionCrudCubit = collectionCrudCubit,
        _globalUserCubit = globalUserCubit,
        _urlRepoImpl = urlRepoImpl,
        super(
          const RssFeedState(
            feedCollections: {},
          ),
        );

  final CollectionsCubit _collectionCubit;
  final CollectionCrudCubit _collectionCrudCubit;
  final GlobalUserCubit _globalUserCubit; // Add this line
  final RssFeedRepo _rssFeedRepo = RssFeedRepo();
  final UrlRepoImpl _urlRepoImpl;

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

  /// IMPROVE REFRESH LOGIC TO NOT DELETE SAME FEED
  /// WILL BE USEFUL WHEN IT HAS READ BOOKMARK OPTIONS TO STORE
  Future<void> refreshCollectionFeed({
    required String collectionId,
  }) async {
    final collection =
        _collectionCubit.getCollection(collectionId: collectionId)?.collection;

    if (collection == null) return;

    final urls = _collectionCubit.state.collectionUrls[collectionId]
            ?.map((ele) => ele.urlModel)
            .whereType<UrlModel>()
            .toList() ??
        <UrlModel>[];

    final feeds = state.feedCollections[collectionId]?.allFeeds ?? <UrlModel>[];

    // Emit a loading state
    final currentCollectionFeed = state.feedCollections[collectionId]!;

    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: currentCollectionFeed.copyWith(
            refreshState: LoadingStates.loading,
          ),
        },
      ),
    );

    await _rssFeedRepo
        .refreshRSSFeed(
      collection: collection,
      urlModels: urls,
      feeds: feeds,
    )
        .then(
      (result) {
        result.fold(
          (error) {
            emit(
              state.copyWith(
                feedCollections: {
                  ...state.feedCollections,
                  collectionId: currentCollectionFeed.copyWith(
                    refreshState: LoadingStates.errorLoading,
                  ),
                },
              ),
            );
          },
          (sucess) async {
            await Future.wait(
              [
                Future(
                  () async {
                    await fetchAllRssFeed(collectionId: collectionId);

                    emit(
                      state.copyWith(
                        feedCollections: {
                          ...state.feedCollections,
                          collectionId:
                              state.feedCollections[collectionId]!.copyWith(
                            refreshState: LoadingStates.loaded,
                          ),
                        },
                      ),
                    );
                  },
                ),
                Future(
                  () async {
                    // Meanwhile updating current updated date for the collection
                    final updatedat = collection.copyWith(
                      updatedAt: DateTime.now().toUtc(),
                    );

                    await _collectionCrudCubit.updateCollection(
                      collection: updatedat,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> getAllRssFeedofCollection({
    required String collectionId,
  }) async {
    // Get The Collection from CollectionCubit
    final currentCollection =
        _collectionCubit.getCollection(collectionId: collectionId)!;

    if (currentCollection.collection == null) return;

    // Check when last fetched
    final lastUpdateDate = currentCollection.collection!.updatedAt;
    final currentDateTime = DateTime.now().toUtc();

    final timeDifference = currentDateTime.difference(lastUpdateDate);

    if (timeDifference.inHours > 8) {
      await refreshCollectionFeed(collectionId: collectionId);
    } else {
      await fetchAllRssFeed(collectionId: collectionId);
    }
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
    final currentCollectionFeed = state.feedCollections[collectionId]!;

    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: currentCollectionFeed.copyWith(
            loadingStates: LoadingStates.loading,
          ),
        },
      ),
    );

    final allFeeds = <UrlModel>[]; // List to collect all feeds

    // for (final urlModel in urlModelList) {
    await for (final result
        in _rssFeedRepo.getAllFeeds(urlModels: urlModelList)) {
      result.fold(
        (failure) {
          // Logger.printLog('Failed to fetch feeds for URL: ');
        },
        (feeds) {
          // Logger.printLog('Got feeds for ${feeds.length}');
          allFeeds.addAll(feeds);
        },
      );
    }

    // Logger.printLog('Fetching feed ended');

    allFeeds.sort(
      (u1, u2) => u2.createdAt.compareTo(u1.createdAt),
    );

    // Update the state with all feeds after all fetching is done
    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: state.feedCollections[collectionId]!.copyWith(
            allFeeds: allFeeds,
            loadingStates: LoadingStates.loaded,
          ),
        },
      ),
    );
  }

  RssFeedModel? getFeedsOfCollection(String collectionId) {
    return state.feedCollections[collectionId];
  }

  Future<void> updateRSSFeed({
    required UrlModel feedUrlModel,
  }) async {
    await _rssFeedRepo
        .updateFeed(
      urlModel: feedUrlModel,
    )
        .then(
      (_) {
        final feeds =
            state.feedCollections[feedUrlModel.collectionId]?.allFeeds;

        if (feeds == null) return;

        final index = feeds.indexWhere(
          (feed) {
            return feed.metaData?.rssFeedUrl ==
                feedUrlModel.metaData?.rssFeedUrl;
          },
        );

        if (index < 0) return;

        feeds[index] = feedUrlModel;

        // state.feedCollections[feedUrlModel.collectionId] = state
        //     .feedCollections[feedUrlModel.collectionId]!
        //     .copyWith(allFeeds: feeds);

        emit(
          state.copyWith(
            feedCollections: {
              ...state.feedCollections,
              feedUrlModel.collectionId: state
                  .feedCollections[feedUrlModel.collectionId]!
                  .copyWith(allFeeds: feeds),
            },
          ),
        );
      },
    );
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
      final updatedUrlModel =
          await _rssFeedRepo.updateBannerImagefromRssFeedUrl(
        urlModel: urlModel,
      );

      return updatedUrlModel;
    } catch (e) {
      return urlModel;
    }
  }
}
