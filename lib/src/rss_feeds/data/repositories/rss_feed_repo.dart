import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/services/rss_data_parsing_service.dart';
import 'package:link_vault/core/services/url_parsing_service.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
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
    required List<UrlModel> urlModels, // it is required don't change this
  }) async* {
    try {
      // Iterate over each urlModel and fetch feeds in parallel (using async for each fetch)
      for (final urlModel in urlModels) {
        final ffeeds = await _localDataSource.fetchRssFeeds(
          firestoreId: '${urlModel.firestoreId}rss',
        );

        if (ffeeds != null && ffeeds.isNotEmpty) {
          // Logger.printLog('got fees in repo local ${ffeeds.length}');
          yield Right(ffeeds); // Emit local data if available
        } else if (urlModel.metaData?.rssFeedUrl != null) {
          // Fetch from the website source if no local data is available
          // Logger.printLog('rssfeedurl: ${urlModel.metaData?.rssFeedUrl}');

          final xmlRawData = await _remoteDataSource.fetchRssFeed(
            urlModel.metaData!.rssFeedUrl!,
          );

          if (xmlRawData != null) {
            final tfeeds = RssXmlParsingService.parseRssFeed(
              xmlRawData,
              collectionId: urlModel.collectionId,
              firestoreId: '${urlModel.firestoreId}rss',
            );

            final faviconUrl = urlModel.metaData?.faviconUrl;
            // Logger.printLog(
            //   'settings: ${urlModel.metaData?.websiteName}, tfeeds: ${tfeeds[0].settings}',
            // );
            // if (faviconUrl != null) {
            for (var i = 0; i < tfeeds.length; i++) {
              tfeeds[i] = tfeeds[i].copyWith(
                metaData: tfeeds[i].metaData?.copyWith(
                      faviconUrl: faviconUrl,
                      websiteName: urlModel.title,
                    ),
                settings: urlModel.settings,
              );
              // }
            }
            yield Right(tfeeds); // Emit fetched data
            await _localDataSource
                .addAllRssFeeds(urlModels: tfeeds)
                .catchError((_) => true);
          }
        }
      }
    } catch (e) {
      yield Left(
        ServerFailure(
          message: 'Something Went Wrong',
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
