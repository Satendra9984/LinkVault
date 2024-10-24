import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';

void main() {
  test('Fetch and print metadata including RSS feed URL', () async {
    // Replace with any URL you'd like to test
    // const testUrl = 'https://www.nytimes.com/international/';
    // const testUrl = 'https://www.youtube.com/';
    // const testUrl = 'https://www.reddit.com/';
    // const testUrl = 'https://x.com/home?lang=en';
    // const testUrl = 'https://play.google.com/';
    // const testUrl = 'https://coindcx.com/';
    // const testUrl = 'https://www.amarujala.com/';
    const testUrl = 'https://www.thehindu.com';
    // const testUrl = 'https://www.livemint.com/';
    // const testUrl = '';
    // const testUrl = '';
    // const testUrl = '';


    // Fetch website metadata
    final (htmlContent, metaData) =
        await UrlParsingService.getWebsiteMetaData(testUrl);

    // Print results
    // print('HTML Content: $htmlContent');
    print('Title: ${metaData?.title}');
    print('Description: ${metaData?.description}');
    print('Website Name: ${metaData?.websiteName}');
    print('Favicon URL: ${metaData?.faviconUrl}');
    print('Banner Image URL: ${metaData?.bannerImageUrl}');
    print('RSS Feed URL: ${metaData?.rssFeedUrl}');

    // Add some basic assertions
    // expect(metaData?.title, isNotNull, reason: 'Title should not be null');
    // expect(metaData?.rssFeedUrl, isNotNull, reason: 'RSS feed URL should not be null');
  });
}
