import 'dart:convert';
import 'package:intl/intl.dart'; // Required for date parsing
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:xml/xml.dart';

// https://pub.dev/packages/xml
class RssXmlParsingService {
  RssXmlParsingService._();

  // Fetch RSS feed content from URL
  static Future<String?> fetchRssFeed(String url) async {
    try {
      final uri = Uri.parse(url);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      // Check response status
      if (response.isRedirect || response.statusCode ~/ 100 != 2) {
        return null;
      }

      // Read the content
      final content = await response.transform(const Utf8Decoder()).join();
      if (response.statusCode == 200) {
        return content;
      } else {
        Logger.printLog('error in "fetchRssFeed" status code error');
        return null;
      }
    } catch (e) {
      Logger.printLog('error in "fetchRssFeed" $e');
      return null;
    }
  }

  // Parse RSS feed XML and return a list of UrlMetaData
  static List<UrlModel> parseRssFeed(
    String xmlString,
    //   {
    //   required CollectionModel collection,
    // }
  ) {
    try {
      final document = XmlDocument.parse(xmlString);
      final feedItems = <UrlModel>[];

      // Extract common metadata from channel (faviconUrl, title, etc.)
      final channel = document.findAllElements('channel').first;

      // Logger.printLog(channel.toXmlString());
      // Global FeedData
      final title = _extractText(channel, 'title');
      final description = _extractText(channel, 'description');
      final websiteUrl = _extractText(channel, 'link');
      final websiteName = extractWebsiteNameFromUrlString(websiteUrl ?? '');
      final faviconUrl = _extractFaviconUrl(channel);

      // Logger.printLog(
      //   'title: ${title}\t description: ${description}\t websiteUrl: ${websiteUrl}\t websiteName: ${websiteName}\t faviconUrl: ${faviconUrl}\t',
      // );

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
          firestoreId: 'firestoreId',
          collectionId: 'collection.id',
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
      return [];
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
      return tag.text;
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

  // Extract banner image URL from the item (e.g., from media:content, enclosure, or other tags)
  static String? _extractBannerImageUrl(XmlElement item) {
    try {
      // Check for media:content (used by many RSS feeds for images)
      final mediaContent = item.findElements('media:content').firstWhere(
            (element) => element.getAttribute('url') != null,
            orElse: () => XmlElement(XmlName('')),
          );
      if (mediaContent.getAttribute('url') != null) {
        return mediaContent.getAttribute('url');
      }

      // Check for enclosure tag with type="image/*"
      final enclosure = item.findElements('enclosure').firstWhere(
            (element) =>
                element.getAttribute('type')?.startsWith('image/') ?? false,
            orElse: () => XmlElement(XmlName('')),
          );
      if (enclosure.getAttribute('url') != null) {
        return enclosure.getAttribute('url');
      }

      // Add more checks if needed for other potential custom tags
      // Try to get image from item description
      final description = item.findElements('description').firstOrNull;
      if (description != null) {
        final descriptionText = description.value ?? '';
        final imgSrcMatch =
            RegExp('<img.*?src="(.*?)"').firstMatch(descriptionText);
        if (imgSrcMatch != null && imgSrcMatch.groupCount >= 1) {
          return imgSrcMatch.group(1);
        }
      }
      // If no image found, return null
      return null;
    } catch (e) {
      return null;
    }
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
