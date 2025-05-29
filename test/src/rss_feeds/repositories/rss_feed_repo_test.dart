import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/src/common/repository_layer/models/url_model.dart';
import 'package:link_vault/src/rss_feeds/data/repositories/rss_feed_repo.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// Mock PathProviderPlatform for unit testing
class MockPathProviderPlatform extends Mock implements PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return '/mock/documents/path';
  }
}

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // <-- Add this line to initialize the binding.

  group('getAllFeeds', () {
    late RssFeedRepo repository;

    setUp(() {
      repository = RssFeedRepo();
      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    test('should return a list of feeds successfully', () async {
      final testFeedUrls = [
        'http://rss.cnn.com/rss/money_latest.rss',
        'https://www.amarujala.com/rss/editors-pick.xml',
        'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
        'https://feeds.washingtonpost.com/rss/sports/blogs-columns?itid=lk_inline_manual_20',
        'https://www.thehindu.com/feeder/default.rss',
      ];
      // Sample mock UrlModels
      final urlModel1 = UrlModel(
        firestoreId: '1',
        collectionId: 'collection1',
        url: 'https://example1.com',
        title: 'Example 1',
        description: 'Sample description for example 1',
        tag: 'Tech',
        isOffline: false,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        isFavourite: true,
        metaData: UrlMetaData(
          favicon: null,
          faviconUrl: 'https://example1.com/favicon.ico',
          bannerImage: null,
          bannerImageUrl: 'https://example1.com/banner.jpg',
          title: 'Example 1',
          description: 'This is example 1',
          websiteName: 'Example Website 1',
          rssFeedUrl: testFeedUrls[0],
        ),
      );

      final urlModel2 = UrlModel(
        firestoreId: '2',
        collectionId: 'collection2',
        url: 'https://example2.com',
        title: 'Example 2',
        description: 'Sample description for example 2',
        tag: 'News',
        isOffline: true,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        isFavourite: false,
        metaData: UrlMetaData(
          favicon: null,
          faviconUrl: 'https://example2.com/favicon.ico',
          bannerImage: null,
          bannerImageUrl: 'https://example2.com/banner.jpg',
          title: 'Example 2',
          description: 'This is example 2',
          websiteName: 'Example Website 2',
          rssFeedUrl: testFeedUrls[1],
        ),
      );

      final mockUrlModels = <UrlModel>[urlModel1, urlModel2];

      // Call getAllFeeds()
      final feedStream = repository.getAllFeeds(urlModels: mockUrlModels);

      // Verify that feeds are fetched correctly
      await for (final result in feedStream) {
        result.fold(
          (failure) {
            fail('Should not fail, but got failure: ${failure.message}');
          },
          (feeds) {
            expect(feeds.length, 2);
            expect(feeds[0].title, 'Example 1');
            expect(feeds[1].title, 'Example 2');
          },
        );
      }
    });
  });
}
