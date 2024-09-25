import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/app_home/services/rss_service.dart';

void main() {
  group('RssXmlParsingService', () {
    test('should fetch and parse RSS feed', () async {
      // Replace this with a valid RSS feed URL for testing
      // final rssFeedUrl = 'https://www.amarujala.com/rss/editors-pick.xml';
      final rssFeedUrl =
          'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml';

      // Fetch the RSS feed
      final rssFeedContent =
          await RssXmlParsingService.fetchRssFeed(rssFeedUrl);
      expect(rssFeedContent, isNotNull);

      // Logger.printLog(rssFeedContent ?? 'Error');
      // Parse the RSS feed
      final urlMetaDataList =
          RssXmlParsingService.parseRssFeed(rssFeedContent!);
      expect(urlMetaDataList, isNotEmpty);

      // Example assertions (customize as needed)
      for (final urlMetaData in urlMetaDataList) {
        Logger.printLog(StringUtils.getJsonFormat(urlMetaData.toJson()));
      }
    });
  });
}
