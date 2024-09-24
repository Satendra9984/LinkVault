import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';

// https://pub.dev/packages/xml
class RssService {
  RssService._();

  static String getBaseUrlFromRssFeedURL(String rssFeedUrl) {
    // Parse the RSS feed URL
    final uri = Uri.parse(rssFeedUrl);

    // Construct the base URL
    final baseUrl = '${uri.scheme}://${uri.host}';

    return baseUrl;
  }

  static Future<bool> isURLRssFeed(String url) async {
    try {
      // Fetch the content from the URL
      final uri = Uri.parse(url);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      // Check response status
      if (response.isRedirect || response.statusCode ~/ 100 != 2) {
        return false;
      }

      // Read the content
      final content = await response.transform(const Utf8Decoder()).join();

      // Parse as XML and check for valid RSS feed structure
      final document = XmlDocument.parse(content);
      final rootElement = document.rootElement;
      if (rootElement.name.local == 'rss' || rootElement.name.local == 'feed') {
        // Check for required RSS/Atom feed elements
        if (rootElement.findElements('channel').isNotEmpty ||
            rootElement.findElements('entry').isNotEmpty) {
          return true;
        }
      }
    } catch (e) {
      print('Error checking RSS feed: $e');
    }
    return false;
  }
}
