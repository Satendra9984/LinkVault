import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/app_home/services/rss_service.dart';
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

  Stream<Either<Failure, List<UrlModel>>> getAllFeeds({
    required List<UrlModel> urlModels,  // it is required don't change this
  }) async* {
    try {
      // Iterate over each urlModel and fetch feeds in parallel (using async for each fetch)
      for (final urlModel in urlModels) {
        final ffeeds = await _localDataSource.fetchRssFeeds(
          firestoreId: '${urlModel.firestoreId}rss',
        );
        if (ffeeds != null && ffeeds.isNotEmpty) {
          yield Right(ffeeds); // Emit local data if available
        } else if (urlModel.metaData?.rssFeedUrl != null) {
          // Fetch from the website source if no local data is available
          final xmlRawData = await _remoteDataSource
              .fetchRssFeed(urlModel.metaData!.rssFeedUrl!);
          if (xmlRawData != null) {
            final tfeeds = RssXmlParsingService.parseRssFeed(
              xmlRawData,
              collectionId: urlModel.collectionId,
              firestoreId: '${urlModel.firestoreId}rss',
            );

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

  // Future<Either<Failure, List<UrlModel>>> getAllFeeds({
  //   required List<UrlModel> urlModels,
  // }) async {
  //   try {
  //     // Create a list to hold all futures
  //     final futures = <Future<List<UrlModel>>>[];
  //     for (final urlModel in urlModels) {
  //       // Add the future to the list
  //       futures.add(
  //         _localDataSource
  //             .fetchRssFeeds(firestoreId: urlModel.firestoreId)
  //             .then((ffeeds) async {
  //           if (ffeeds != null) {
  //             return ffeeds; // Return fetched feeds from local data source
  //           }
  //           // Fetch from the website source if local data is not available
  //           if (urlModel.metaData?.rssFeedUrl != null) {
  //             final xmlRawData = await _remoteDataSource.fetchRssFeed(
  //               urlModel.metaData!.rssFeedUrl!,
  //             );
  //             if (xmlRawData != null) {
  //               final fetchedFeeds = RssXmlParsingService.parseRssFeed(
  //                 xmlRawData,
  //                 collectionId: urlModel.collectionId,
  //                 firestoreId: urlModel.firestoreId,
  //               );
  //               await _localDataSource.addAllRssFeeds(urlModels: fetchedFeeds);
  //               return fetchedFeeds;
  //             }
  //           }
  //           return []; // Return empty list if nothing is fetched
  //         }),
  //       );
  //     }
  //     // Wait for all futures to complete
  //     final results = await Future.wait(futures);
  //     // Flatten the list of lists into a single list
  //     final feeds = results.expand((feedList) => feedList).toList();
  //     return Right(feeds);
  //   } catch (e) {
  //     return Left(
  //       GeneralFailure(message: 'Something Went Wrong', statusCode: 402),
  //     );
  //   }
  // }

  Future<Either<Failure, bool>> deleteAllFeeds({
    required String firestoreId,
  }) async {
    try {
      final isDeleted = await _localDataSource.deleteRssFeeds(
        firestoreId: '${firestoreId}rss',
      );

      return Right(isDeleted);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something went wrong',
          statusCode: 403,
        ),
      );
    }
  }
}
