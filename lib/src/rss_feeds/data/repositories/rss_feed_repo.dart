import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/services/rss_data_parsing_service.dart';
import 'package:link_vault/core/services/url_parsing_service.dart';
import 'package:link_vault/src/rss_feeds/data/data_sources/local_data_source.dart';
import 'package:link_vault/src/rss_feeds/data/data_sources/remote_data_source.dart';

class RssFeedRepo {
  RssFeedRepo({
    RemoteDataSource? remoteDataSource,
    LocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? RemoteDataSource(),
        _localDataSource = localDataSource ?? LocalDataSource(isar: null);

  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  // final LocalImageDataSource _localImageDataSource = LocalImageDataSource();
  Stream<Either<Failure, List<UrlModel>>> getAllFeeds({
    required List<UrlModel> urlModels,
  }) async* {
    try {
      // Run fetches in parallel with throttling
      final feedResults = await Future.wait(
        urlModels.map(fetchFeed),
      );

      // Emit each result as it arrives
      for (final result in feedResults) {
        yield result;
      }
    } catch (e) {
      // Catch and yield a general error if something goes wrong
      yield Left(
        ServerFailure(
          message: 'Something went wrong while fetching feeds',
          statusCode: 402,
        ),
      );
    }
  }

  // Helper to fetch feeds for each URL, allowing for concurrent execution
  Future<Either<Failure, List<UrlModel>>> fetchFeed(
    UrlModel urlModel,
  ) async {
    try {
      // Attempt to load cached data first
      final cachedFeeds = await _localDataSource.fetchRssFeeds(
        firestoreId: '${urlModel.firestoreId}rss',
      );

      // Emit cached feeds immediately if they exist
      if (cachedFeeds != null && cachedFeeds.isNotEmpty) {
        return Right(cachedFeeds);
      }

      // Proceed to remote fetch if no local data is available and RSS URL exists
      if (urlModel.metaData?.rssFeedUrl != null) {
        final xmlRawData = await _remoteDataSource.fetchRssFeed(
          urlModel.metaData!.rssFeedUrl!,
        );

        if (xmlRawData != null) {
          // Parse and update metadata
          final fetchedFeeds = RssXmlParsingService.parseRssFeed(
            xmlRawData,
            collectionId: urlModel.collectionId,
            firestoreId: '${urlModel.firestoreId}rss',
          );

          // Update each feed with the favicon and settings from UrlModel metadata
          final faviconUrl = urlModel.metaData?.faviconUrl;
          for (var i = 0; i < fetchedFeeds.length; i++) {
            fetchedFeeds[i] = fetchedFeeds[i].copyWith(
              metaData: fetchedFeeds[i].metaData?.copyWith(
                    faviconUrl: faviconUrl,
                    websiteName: urlModel.title,
                  ),
              settings: urlModel.settings,
            );
          }

          // Store the fetched feeds locally for future quick access
          await _localDataSource
              .addAllRssFeeds(urlModels: fetchedFeeds)
              .catchError((_) => true);

          return Right(fetchedFeeds);
        }
      }

      // Return an empty list if nothing is available
      return const Right([]);
    } catch (e) {
      // Capture and return failure per URL fetch to prevent termination of the entire process
      return Left(
        ServerFailure(
          message: 'Failed to fetch feeds for ${urlModel.title}',
          statusCode: 402,
        ),
      );
    }
  }

  Future<Either<Failure, bool>> refreshRSSFeed({
    required CollectionModel collection,
    required List<UrlModel> urlModels, // ALL URLMODELS OF THE COLLECTION
    required List<UrlModel> feeds, // CURRENT FEEDS
  }) async {
    try {
      for (final urlId in collection.urls) {
        await deleteAllFeeds(firestoreId: urlId);
      }

      final newlyfectedfeeds = <UrlModel>[];
      for (final urlModel in urlModels) {
        if (urlModel.metaData?.rssFeedUrl == null) continue;

        // FETCHING NEW FRESH FEEDS
        final xmlRawData = await _remoteDataSource.fetchRssFeed(
          urlModel.metaData!.rssFeedUrl!,
        );

        if (xmlRawData == null) continue;

        //
        final tfeeds = RssXmlParsingService.parseRssFeed(
          xmlRawData,
          collectionId: urlModel.collectionId,
          firestoreId: '${urlModel.firestoreId}rss',
        );

        final faviconUrl = urlModel.metaData?.faviconUrl;
        for (var i = 0; i < tfeeds.length; i++) {
          tfeeds[i] = tfeeds[i].copyWith(
            metaData: tfeeds[i].metaData?.copyWith(
                  faviconUrl: faviconUrl,
                  websiteName: urlModel.title,
                ),
            settings: urlModel.settings,
          );
        }

        newlyfectedfeeds.addAll(tfeeds);
      }

      // Replace newly fetched feeds' element with current feeds' if already present
      for (var i = 0; i < newlyfectedfeeds.length; i++) {
        final newlyFetchedFeed = newlyfectedfeeds[i];

        final existingFeed = feeds.firstWhere(
          (feed) =>
              feed.metaData?.rssFeedUrl ==
              newlyFetchedFeed.metaData?.rssFeedUrl,
          orElse: () =>
              newlyFetchedFeed, // If not found, return the new feed itself
        );

        // If the feed already exists, replace the existing feed in `newlyfectedfeeds`
        if (existingFeed.metaData?.rssFeedUrl ==
            newlyFetchedFeed.metaData?.rssFeedUrl) {
          newlyfectedfeeds[i] = existingFeed.copyWith(
            settings: newlyfectedfeeds[i].settings,
          );
        }
      }

      // Finally, store the newly updated feeds
      await _localDataSource.addAllRssFeeds(urlModels: newlyfectedfeeds);

      return const Right(true); // Return success after processing feeds
    } catch (e) {
      return Left(
        GeneralFailure(
          message: 'Something Went Wrong',
          statusCode: 402,
        ),
      );
    }
  }

  Future<Either<Failure, bool>> deleteAllFeeds({
    required String firestoreId,
  }) async {
    try {
      await _localDataSource.deleteRssFeeds(
        firestoreId: '${firestoreId}rss',
      );

      return const Right(true);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something went wrong',
          statusCode: 403,
        ),
      );
    }
  }

  Future<Either<Failure, bool>> updateFeed({
    required UrlModel urlModel,
  }) async {
    try {
      await _localDataSource.updateRssFeed(
        urlModel: urlModel,
      );

      return const Right(true);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something went wrong',
          statusCode: 403,
        ),
      );
    }
  }

  Future<UrlModel> updateBannerImagefromRssFeedUrl({
    required UrlModel urlModel,
  }) async {
    final rssFeedUrl = urlModel.metaData?.rssFeedUrl;

    if (rssFeedUrl == null) return urlModel;

    if (urlModel.metaData!.bannerImageUrl != null &&
        urlModel.metaData!.bannerImageUrl!.isEmpty) {
      return urlModel;
    }
    try {
      final bannerImageUrl = await compute(
        UrlParsingService.fetchParseAndExtractBanner,
        rssFeedUrl,
      );

      final updatedUrlModel = urlModel.copyWith(
        metaData: urlModel.metaData?.copyWith(
          bannerImageUrl: bannerImageUrl ?? '',
        ),
      );

      await _localDataSource.updateRssFeed(
        urlModel: updatedUrlModel,
      );

      return updatedUrlModel;
    } catch (e) {
      return urlModel;
    }
  }
}
