import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Required for date parsing
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/app_home/services/html_parsing_service.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:xml/xml.dart';

class RssXmlParsingService {
  RssXmlParsingService._();

// static Future<XmlDocument?> fetchRssFeed(String url) async {
//   try {
//     final uri = Uri.parse(url);
//     final client = HttpClient()
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

//     final request = await client.getUrl(uri);
//     final response = await request.close();

//     if (response.isRedirect || response.statusCode ~/ 100 != 2) {
//       return null;
//     }

//     final content = await response.transform(const Utf8Decoder()).join();
//     if (response.statusCode == 200) {
//       return XmlDocument.parse(content);
//     } else {
//       Logger.printLog('error in "fetchRssFeed" status code error');
//       return null;
//     }
//   } catch (e) {
//     Logger.printLog('Error fetching rss page: $e');
//     return null;
//   }
// }

  static Future<XmlDocument?> fetchRssFeed(String url) async {
    final client = http.Client();
    try {
      // First, try the original URL (HTTP or HTTPS)
      var response = await client.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        return XmlDocument.parse(response.body);
      } else {
        Logger.printLog(
          'HTTP error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // If the original URL failed and it was HTTP, try HTTPS
      if (url.startsWith('https://')) {
        final httpsUrl = url.replaceFirst('https://', 'http://');
        response = await client.get(Uri.parse(httpsUrl)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('HTTPS connection timed out');
          },
        );

        if (response.statusCode == 200) {
          return XmlDocument.parse(response.body);
        } else {
          Logger.printLog(
            'HTTPS error ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      } else if (url.startsWith('http://')) {
        final httpsUrl = url.replaceFirst('http://', 'https://');
        response = await client.get(Uri.parse(httpsUrl)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('HTTPS connection timed out');
          },
        );

        if (response.statusCode == 200) {
          return XmlDocument.parse(response.body);
        } else {
          Logger.printLog(
            'HTTPS error ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      }

      Logger.printLog('Failed to fetch RSS feed from both HTTP and HTTPS');
      return null;
    } catch (e) {
      if (e is TimeoutException) {
        Logger.printLog('Connection timed out: $e');
      } else if (e is SocketException) {
        Logger.printLog('Socket error: $e');
      } else if (e is FormatException) {
        Logger.printLog('Invalid URL format: $e');
      } else if (e is XmlParserException) {
        Logger.printLog('XML parsing error: $e');
      } else {
        Logger.printLog('Unexpected error in fetchRssFeed: $e');
      }
      return null;
    } finally {
      client.close();
    }
  }

  static String getXmlContent(XmlNode node, {int indent = 0}) {
    final buffer = StringBuffer();

    void processNode(XmlNode node, int indent) {
      if (node is XmlElement) {
        // Build opening tag with attributes
        final attributes = node.attributes
            .map((attr) => '${attr.name.local}="${attr.value}"')
            .join(' ');
        final openingTag = attributes.isEmpty
            ? node.name.local
            : '${node.name.local} $attributes';
        buffer.write('${' ' * indent}<$openingTag>\n');

        // Process child nodes
        for (final child in node.children) {
          processNode(child, indent + 2);
        }

        // Build closing tag
        buffer.write('${' ' * indent}</${node.name.local}>\n');
      } else if (node is XmlText) {
        final trimmedText = node.text.trim();
        if (trimmedText.isNotEmpty) {
          buffer.write('${' ' * indent}$trimmedText\n');
        }
      } else if (node is XmlCDATA) {
        buffer.write('${' ' * indent}${node.text}\n');
      }
    }

    processNode(node, indent);
    return buffer.toString();
  }

  // Parse RSS feed XML and return a list of UrlMetaData
  static List<UrlModel> parseRssFeed(
    String xmlString, {
    required String collectionId,
    required String firestoreId,
  }) {
    final feedItems = <UrlModel>[];
    try {
      final document = XmlDocument.parse(xmlString);

      // Extract the main channel/ feed element
      final channel = document.findAllElements('rdf:RDF').firstOrNull ??
          document.findAllElements('channel').firstOrNull ??
          document.findAllElements('feed').first;

      // Extract common metadata (faviconUrl, title, etc.) from the channel
      final title = extractText(channel, 'title');
      final description = extractText(channel, 'description');
      final websiteUrl = extractText(channel, 'link');

      final websiteName = extractWebsiteNameFromUrlString(websiteUrl ?? '');
      final faviconUrl = _extractFaviconUrl(channel);

      // Extract feeds (either 'item' or 'entry' elements)
      var feeds = document.findAllElements('item');
      if (feeds.isEmpty) {
        feeds = document.findAllElements('entry');
      }

      // Extract individual feed items
      for (final item in feeds) {
        // printXmlContent(item);

        final itemTitle = extractText(item, 'title');
        final itemDescription = extractText(item, 'description');
        final itemLink = extractText(item, 'link');
        final pubDate = _extractDate(item);
        // this function removes some elements so keep in mind
        final bannerImageUrl = _extractBannerImageUrl(item);
        // Logger.printLog(
        //   'pubDate: ${pubDate?.toIso8601String()}\n'
        //   'title: ${itemTitle}\n'
        //   'desc: $itemDescription\n'
        //   'link: $itemLink\n'
        //   'bannerUrl: $bannerImageUrl',
        // );
        // Logger.printLog('\n\n');

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
          url: websiteUrl ?? itemLink ?? '',
          title: title ?? '',
          description: description,
          tag: 'tag',
          isOffline: false,
          createdAt: pubDate ?? DateTime.now().toUtc(),
          updatedAt: pubDate ?? DateTime.now().toUtc(),
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

  static String? extractElementsFromDocument(
    XmlDocument element,
    String tagName,
  ) {
    try {
      final tag = element.findAllElements(tagName).first;
      return tag.text.trim();
    } catch (e) {
      return null;
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
  static String? extractText(XmlElement element, String tagName) {
    try {
      final tag = element.findElements(tagName).first;
      final text = tag.text.trim();

      return HtmlParsingService.extractTextFromHtml(text);
    } catch (e) {
      return null;
    }
  }

  // Extract favicon URL from channel or image tag
  static String? _extractFaviconUrl(XmlElement channel) {
    try {
      final imageTag = channel.findElements('image').first;
      final faviconUrl = extractText(imageTag, 'url');
      return faviconUrl;
    } catch (e) {
      return null;
    }
  }

  static String? _extractBannerImageUrl(XmlElement itemElement) {
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

    // Collect all media elements
    final mediaElements = itemElement
        .findElements('media:content')
        .followedBy(itemElement.findElements('media:thumbnail'))
        .followedBy(itemElement.findElements('enclosure'));

    // Search through media-specific elements for image URLs
    for (final mediaElement in mediaElements) {
      final url = mediaElement.getAttribute('url') ?? '';
      if (_isImageUrl(url)) {
        return url;
      }
    }

    // If no media-specific URL is found, continue searching other attributes
    for (final element in itemElement.descendants.whereType<XmlElement>()) {
      for (final attribute in element.attributes) {
        final url = attribute.value;
        if (_isImageUrl(url)) {
          return url;
        }
      }
    }

    // Return empty string or fallback if no image URL is found
    return null; // You can replace this with a fallback URL if necessary
  }

// Helper function to check if a URL is likely an image
  static bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('.svg') ||
        lowerUrl.contains('.bmp') ||
        lowerUrl.contains('.webp');
  }

  // Extract publication date from the item and convert it to DateTime format
  static DateTime? _extractDate(XmlElement item) {
    try {
      // Extract from possible tags like pubDate, published, etc.

      final dateString =
          extractText(item, 'pubDate') ?? extractText(item, 'published');

      if (dateString != null) {
        // Parse the date into DateTime using DateFormat
        return _parseDate(dateString);
      }
      return null;
    } catch (e) {
      // Logger.printLog('[rss]: pubdate _extractDate: $e');
      return null;
    }
  }

  // Helper function to parse date string into DateTime
  static DateTime? _parseDate(String dateString) {
    try {
      // Common RSS date formats (RFC822 for example)
      final rfc822Format = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US');
      // Logger.printLog('[rss]: pubdate rfc822Format: $rfc822Format');

      return rfc822Format.parse(dateString);
    } catch (e) {
      // Logger.printLog('[rss]: pubdate _parseDate: $e');

      return null;
    }
  }

  static String? getBaseUrlFromRssData(XmlElement channel) {
    try {
      // Check if there is an RSS <link> element with a direct value
      final rssLinkElement = channel.findElements('link').firstWhere(
            (element) => element.children.isNotEmpty,
            orElse: () => XmlElement(XmlName('')),
          );

      if (rssLinkElement.name.local == 'link' &&
          rssLinkElement.text.isNotEmpty) {
        final baseUrl = rssLinkElement.text.trim();
        return _validateAndFixUrl(baseUrl);
      }

      // If not found, check for Atom <link> elements with href attribute
      final atomLinkElements = channel.findAllElements('link');
      Logger.printLog('links: $atomLinkElements');
      if (atomLinkElements.isEmpty) {
        return null;
      }

      // Atom case (where rel="alternate" points to the actual website)
      final alternateLinkElement = atomLinkElements.firstWhere(
        (element) => element.getAttribute('rel') == 'alternate',
        orElse: () => XmlElement(XmlName('')),
      );

      final baseUrl = alternateLinkElement.getAttribute('href')?.trim();
      return _validateAndFixUrl(baseUrl);
    } catch (e) {
      Logger.printLog('Error in getBaseUrlFromRssData $e');
      return null;
    }
  }

  // static String? getBaseUrlFromRssData(XmlElement channel) {
  //   try {
  //     // If no <channel>/<link>, check for Atom <feed> structure
  //     final atomLinkElements = channel.findAllElements('link');
  //     Logger.printLog('links: ${atomLinkElements.toString()}');
  //     if (atomLinkElements.isEmpty) {
  //       return null;
  //     }

  //     final alternateLinkElement = atomLinkElements.firstWhere(
  //       (element) => element.getAttribute('rel') == 'alternate',
  //     );
  //     // Atom case (where rel="alternate" points to the actual website)
  //     final baseUrl = alternateLinkElement.getAttribute('href')?.trim();
  //     return _validateAndFixUrl(baseUrl);

  //   } catch (e) {
  //     Logger.printLog('Error in getBaseUrlFromRssData $e');
  //     return null;
  //   }
  // }

  // Helper function to handle relative URLs and invalid cases
  static String? _validateAndFixUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    // Check if it's a relative URL (e.g., "/home")
    if (url.startsWith('/')) {
      // You might want to concatenate the domain or use a fallback base URL here
      // Example fallback: "https://example.com" + url
      return null; // Or return a valid concatenated URL if needed
    }

    // Validate if the URL starts with a valid protocol
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Invalid URL, return null
    return null;
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
