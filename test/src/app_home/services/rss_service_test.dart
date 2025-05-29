import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/core/services/rss_data_parsing_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              true; // Accept all certificates
  }
}

void main() {
  // Apply the custom HTTP overrides before running tests
  HttpOverrides.global = MyHttpOverrides();
  group('RssXmlParsingService', () {
    test('should fetch and parse RSS feed', () async {
      final testFeedUrls = [
        'http://rss.cnn.com/rss/money_latest.rss',
        'https://www.amarujala.com/rss/editors-pick.xml',
        'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
        'https://feeds.washingtonpost.com/rss/sports/blogs-columns?itid=lk_inline_manual_20',
        'https://www.thehindu.com/feeder/default.rss',
      ];

      // Replace this with a valid RSS feed URL for testing
      final rssFeedUrl = testFeedUrls[4];

      // Parse the RSS feed
      final urlMetaDataList = RssXmlParsingService.parseRssFeed(
        rssFeedUrl,
        collectionId: 'collectionId',
        firestoreId: 'firestoreId',
      );
      expect(urlMetaDataList, isNotEmpty);
      // Logger.printLog(urlMetaDataList.length.toString());
      // Example assertions (customize as needed)
      for (final urlMetaData in urlMetaDataList) {
        // Logger.printLog(StringUtils.getJsonFormat(urlMetaData.toJson()));
      }
    });
  });
}
