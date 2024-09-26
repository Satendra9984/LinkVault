import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart'; // Required for date parsing
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:xml/xml.dart';

// https://pub.dev/packages/xml
class RssXmlParsingService {
  RssXmlParsingService._();

  // Parse RSS feed XML and return a list of UrlMetaData
  static List<UrlModel> parseRssFeed(
    String xmlString, {
    required String collectionId,
    required String firestoreId,
  }) {
    final feedItems = <UrlModel>[];
    try {
      final document = XmlDocument.parse(xmlString);

      // Extract common metadata from channel (faviconUrl, title, etc.)
      final channel = document.findAllElements('channel').first;

      // Logger.printLog(channel.toXmlString());
      // Global FeedData
      final title = _extractText(channel, 'title');
      final description = _extractText(channel, 'description');
      final websiteUrl = _extractText(channel, 'link');
      final websiteName = extractWebsiteNameFromUrlString(websiteUrl ?? '');
      final faviconUrl = _extractFaviconUrl(channel);

      // Extract individual feed items
      for (final item in document.findAllElements('item')) {
        final itemTitle = _extractText(item, 'title');
        final itemDescription = _extractText(item, 'description');
        final itemLink = _extractText(item, 'link');
        final bannerImageUrl = _extractBannerImageUrl(item);
        final pubDate = _extractDate(item);

        final urlMetaData = UrlMetaData(
          title: itemTitle,
          description: itemDescription,
          websiteName: websiteName,
          favicon: null,
          faviconUrl: faviconUrl,
          bannerImage: null,
          bannerImageUrl: bannerImageUrl, // Optional: extract or use fallback
          rssFeedUrl: itemLink,
        );

        final urlModel = UrlModel(
          firestoreId: firestoreId,
          collectionId: collectionId,
          url: itemLink ?? websiteUrl ?? '',
          title: title ?? '',
          description: description,
          tag: 'tag',
          isOffline: false,
          createdAt: pubDate ?? DateTime.now(),
          updatedAt: pubDate ?? DateTime.now(),
          isFavourite: false,
          metaData: urlMetaData,
        );

        feedItems.add(urlModel);
      }

      return feedItems;
    } catch (e) {
      Logger.printLog('error in "parseRssFeed" $e');
      return feedItems;
    }
  }

  static String extractWebsiteNameFromUrlString(String url) {
    try {
      final uri = Uri.parse(url);
      var host = uri.host;

      // Remove 'www.' if present
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }

      // Get the domain name
      final domainParts = host.split('.');
      if (domainParts.length > 2) {
        return domainParts[domainParts.length - 2];
      } else if (domainParts.length > 1) {
        return domainParts[0];
      } else {
        return host; // In case it's a local or unconventional domain
      }
    } catch (e) {
      return ''; // Return empty string if URL parsing fails
    }
  }

  // Helper to extract text from an XML element
  static String? _extractText(XmlElement element, String tagName) {
    try {
      final tag = element.findElements(tagName).first;
      return tag.text.trim();
    } catch (e) {
      return null;
    }
  }

  // Extract favicon URL from channel or image tag
  static String? _extractFaviconUrl(XmlElement channel) {
    try {
      final imageTag = channel.findElements('image').first;
      final faviconUrl = _extractText(imageTag, 'url');
      return faviconUrl;
    } catch (e) {
      return null;
    }
  }

  // Helper function to check if a URL is likely an image
  static bool _isImageUrl(String url) {
    return url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.gif');
  }

  static String _extractBannerImageUrl(XmlElement itemElement) {
    // List of elements to exclude from the search for media URLs
    final excludedElements = [
      'title',
      'description',
      'pubDate',
      'link',
      'guid',
      'category domain',
      'dc:creator',
    ];

    // Remove the excluded elements from the itemElement
    itemElement.children.removeWhere((node) {
      if (node is XmlElement) {
        return excludedElements.contains(node.name.local);
      }
      return false; // Keep non-XmlElement nodes (like text nodes)
    });

    // Logger.printLog('Cleaned xml:');
    // Logger.printLog(itemElement.toXmlString());

    // Search through all attributes that might have an image URL
    for (final element in itemElement.descendants.whereType<XmlElement>()) {
      for (final attribute in element.attributes) {
        final url = attribute.value;
        if (_isImageUrl(url)) {
          return url;
        }
      }
    }

    // Return empty string or fallback if no image URL is found
    return ''; // You can replace this with a fallback URL if necessary
  }

  // Extract publication date from the item and convert it to DateTime format
  static DateTime? _extractDate(XmlElement item) {
    try {
      // Extract from possible tags like pubDate, published, etc.
      final dateString =
          _extractText(item, 'pubDate') ?? _extractText(item, 'published');
      if (dateString != null) {
        // Parse the date into DateTime using DateFormat
        return _parseDate(dateString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper function to parse date string into DateTime
  static DateTime? _parseDate(String dateString) {
    try {
      // Common RSS date formats (RFC822 for example)
      final rfc822Format = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US');
      return rfc822Format.parse(dateString);
    } catch (e) {
      return null;
    }
  }

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
