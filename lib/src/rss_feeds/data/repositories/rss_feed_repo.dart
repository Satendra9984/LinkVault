import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/app_home/services/rss_service.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
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
          // Logger.printLog('got fees in repo local ${ffeeds}');
          yield Right(ffeeds); // Emit local data if available
        } else if (urlModel.metaData?.rssFeedUrl != null) {
          // Fetch from the website source if no local data is available
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
            // Logger.printLog('copyingtitle: ${urlModel.title}');
            if (faviconUrl != null) {
              for (var i = 0; i < tfeeds.length; i++) {
                tfeeds[i] = tfeeds[i].copyWith(
                  metaData: tfeeds[i].metaData?.copyWith(
                        faviconUrl: faviconUrl,
                        websiteName: urlModel.title,
                      ),
                );
              }
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

  Future<Either<Failure, bool>> deleteAllFeeds({
    required String firestoreId,
  }) async {
    try {
      await Future.wait([
        // 1. Delete all RSS feeds
        _localDataSource.deleteRssFeeds(
          firestoreId: '${firestoreId}rss',
        ),

        // 2. Fetch feeds and delete associated images
        // Future(() async {
        //   final ffeeds = await _localDataSource.fetchRssFeeds(
        //     firestoreId: '${firestoreId}rss',
        //   );

        //   if (ffeeds != null && ffeeds.isNotEmpty) {
        //     for (final feed in ffeeds) {
        //       if (feed.metaData?.bannerImageUrl != null) {
        //         await _localImageDataSource.deleteImageData(
        //           imageUrl: feed.metaData!.bannerImageUrl!,
        //         );
        //       }
        //     }
        //   }
        // }),
      ]);

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

    if (urlModel.metaData!.bannerImageUrl != null) {
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
      // Logger.printLog(
      //   '[rss] : bannerImageRSS ${StringUtils.getJsonFormat(updatedUrlModel.metaData?.toJson())}',
      // );
      await _localDataSource.updateRssFeed(
        urlModel: updatedUrlModel,
      );

      return updatedUrlModel;
    } catch (e) {
      return urlModel;
    }
  }
}
