// ignore_for_file: public_member_api_docs

import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlParsingService {
// Function to fetch webpage content
  Future<String?> fetchWebpageContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        Logger.printLog('error in "fetchWebpageContent" statuscode error');
        return null;
      }
    } catch (e) {
      Logger.printLog('error in "fetchWebpageContent" $e');
      return null;
    }
  }

// Function to extract title
  String? extractTitle(Document document) {
    return document.head?.querySelector('title')?.text;
  }

// Function to extract description
  String? extractDescription(Document document) {
    try {
      final description = document.head
              ?.querySelector('meta[name="description"]')
              ?.attributes['content'] ??
          document.head
              ?.querySelector('meta[property="og:description"]')
              ?.attributes['content'];
      return description;
    } catch (e) {
      Logger.printLog('error in "extractDescription" $e');
      return null;
    }
  }

// Function to extract image URL
  // String? extractImageUrl(Document document) {
  //   try {
  //     final imageUrl = document.head
  //             ?.querySelector('meta[property="og:image"]')
  //             ?.attributes['content'] ??
  //         document.head
  //             ?.querySelector('meta[name="twitter:image"]')
  //             ?.attributes['content'];
  //     return imageUrl;
  //   } catch (e) {
  //     Logger.printLog('error in "extractImageUrl" $e');

  //     return null;
  //   }
  // }

  String? extractImageUrl(Document document) {
    try {
      // Try to find the first image element on the page in body
      final imageElements = document.body?.querySelectorAll('img');
      if (imageElements != null && imageElements.isNotEmpty) {
        // Filter out small images or irrelevant ones
        const minBannerArea = 90000;
        const minBannerWidth = 600;
        const minBannerHeight = 150;

        Element? largestImageElement;
        for (final img in imageElements) {
          final width = int.tryParse(img.attributes['width'] ?? '') ?? 0;
          final height = int.tryParse(img.attributes['height'] ?? '') ?? 0;
          final area = width * height;

          if (area >= minBannerArea &&
              width >= minBannerWidth &&
              height >= minBannerHeight) {
            largestImageElement = img;
            break;
          }
        }

        if (largestImageElement != null) {
          final src = largestImageElement.attributes['src'];
          if (src != null) {
            return src;
          }
        }
      }
      // List of possible meta tag attributes for images
      final metaTags = [
        'meta[property="og:image"]',
        'meta[name="twitter:image"]',
        'meta[itemprop="image"]',
      ];

      // Try to find the image URL from meta tags
      for (final metaTag in metaTags) {
        final element = document.head?.querySelector(metaTag);
        if (element != null && element.attributes['content'] != null) {
          return element.attributes['content'];
        }
      }

      return null;
    } catch (e) {
      // Improved error logging
      Logger.printLog('error in "extractImageUrl" $e');
      return null;
    }
  }

// Function to extract website name
  String? extractWebsiteName(Document document) {
    try {
      final websiteName = document.head
          ?.querySelector('meta[property="og:site_name"]')
          ?.attributes['content'];

      return websiteName;
    } catch (e) {
      Logger.printLog('error in "extractWebsiteName" $e');

      return null;
    }
  }

// Function to extract website logo
  String? extractWebsiteLogoUrl(Document document) {
    try {
      final logoUrl = document.head
              ?.querySelector('link[rel="icon"]')
              ?.attributes['href'] ??
          document.head
              ?.querySelector('link[rel="shortcut icon"]')
              ?.attributes['href'];
      return logoUrl;
    } catch (e) {
      Logger.printLog('error in "extractWebsiteLogoUrl" $e');
      return null;
    }
  }

// Function to fetch image as Uint8List
  Future<Uint8List?> fetchImageAsUint8List(String imageUrl) async {
    try {
      Logger.printLog('websiteImageUrl: $imageUrl');
      if (imageUrl.isEmpty) return null;
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Logger.printLog('websiteImage ${response.bodyBytes.length}');
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      Logger.printLog('error in "fetchImageAsUint8List" $e');

      return null;
    }
  }

// Function to handle relative URLs
  String handleRelativeUrl(String url, String baseUrl) {
    if (url.startsWith('http')) {
      return url;
    }
    return Uri.parse(baseUrl).resolve(url).toString();
  }

// Main parsing function
  Future<(String?, UrlMetaData?)> getWebsiteMetaData(String url) async {
    final htmlContent = await fetchWebpageContent(url);

    if (htmlContent == null) {
      return (null,null);
    }
    final document = html_parser.parse(htmlContent);
    final metaData = <String, dynamic>{};

    metaData['title'] = extractTitle(document);
    metaData['description'] = extractDescription(document);
    metaData['websiteName'] = extractWebsiteName(document);

    var websiteLogoUrl = extractWebsiteLogoUrl(document);

    // Handle relative URLs
    if (websiteLogoUrl != null) {
      websiteLogoUrl = handleRelativeUrl(websiteLogoUrl, url);
      metaData['banner_image'] = await fetchImageAsUint8List(websiteLogoUrl);
    }

    var imageUrl = extractImageUrl(document);
    Logger.printLog('imageUrl : $imageUrl');
    if (imageUrl != null) {
      imageUrl = handleRelativeUrl(imageUrl, url);
      metaData['favicon'] = await fetchImageAsUint8List(imageUrl);
    }

    // Fetch image as Uint8List
    final metaDataObject = UrlMetaData.fromJson(metaData);

    return (htmlContent, metaDataObject);
  }
}
