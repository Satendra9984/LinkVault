// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:path_provider/path_provider.dart';

class UrlParsingService {
// Function to fetch webpage content
  static Future<String?> fetchWebpageContent(String url) async {
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
  static String? extractTitle(Document document) {
    final title = document.head?.querySelector('title')?.text;

    if (title == null) return null;

    Logger.printLog('title: $title');
    return StringUtils.getUnicodeString(title);
  }

// Function to extract description
  static String? extractDescription(Document document) {
    try {
      final description = document.head
              ?.querySelector('meta[name="description"]')
              ?.attributes['content'] ??
          document.head
              ?.querySelector('meta[property="og:description"]')
              ?.attributes['content'];

      if (description == null) return null;
      return StringUtils.getUnicodeString(description);
    } catch (e) {
      Logger.printLog('error in "extractDescription" $e');
      return null;
    }
  }

  static String? extractImageUrl(Document document) {
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
          final width = int.tryParse(img.attributes['width'] ?? '') ?? 1;
          final height = int.tryParse(img.attributes['height'] ?? '') ?? 1;
          final area = width * height;
          final aspectRatio = width ~/ height;

          if (area >= minBannerArea &&
              (width >= minBannerWidth || height >= minBannerHeight) &&
              (aspectRatio >= 1.5 && aspectRatio <= 6)) {
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
  static String? extractWebsiteName(Document document) {
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
  static String? extractWebsiteLogoUrl(Document document) {
    try {
      // List of possible favicon selectors
      final selectors = [
        'link[rel="icon"]',
        'link[rel="shortcut icon"]',
        'link[rel="apple-touch-icon"]',
        'link[rel="apple-touch-icon-precomposed"]',
        'link[rel="mask-icon"]',
        'link[rel="manifest"]',
        'meta[itemprop="image"]', // Some sites use schema.org for favicons
      ];

      for (final selector in selectors) {
        final element = document.head?.querySelector(selector);
        if (element != null) {
          final href = element.attributes['href'];
          if (href != null) {
            return href;
          }
        }
      }

      // Fallback: try to find favicon in the root directory
      return '/favicon.ico';
    } catch (e) {
      Logger.printLog('error in "extractWebsiteLogoUrl" $e');
      return null;
    }
  }

// Function to fetch image as Uint8List
  static Future<Uint8List?> fetchImageAsUint8List(
    String imageUrl, {
    required int maxSize,
  }) async {
    try {
      Logger.printLog('websiteImageUrl: $imageUrl');
      if (imageUrl.isEmpty) return null;
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final originalImageBytes = response.bodyBytes;
        return getCompressedImage(originalImageBytes, maxSize: maxSize);
      }
      return null;
    } catch (e) {
      Logger.printLog('error in "fetchImageAsUint8List" $e');

      return null;
    }
  }

  static Future<Uint8List?> getCompressedImage(
    Uint8List originalImageBytes, {
    required int maxSize,
  }) async {
    final compressedImage = await ImageUtils.compressImage(originalImageBytes);

    Logger.printLog('Original Image:  ${originalImageBytes.length}');
    Logger.printLog('compressedImage: ${compressedImage?.length}');

    // final stringBase64 = StringUtils.convertUint8ListToBase64(compressedImage);
    // if (stringBase64 == null) return null;
    // final compressedBase64String = StringUtils.compressString(stringBase64);

    // if (compressedBase64String == null) return null;

    // Logger.printLog('compressedImage: ${compressedBase64String.length}');

    return compressedImage == null || compressedImage.length > maxSize
        ? null
        : compressedImage;
  }

// Function to handle relative URLs
  static String handleRelativeUrl(String url, String baseUrl) {
    try {
      if (url.startsWith('http')) {
        return url;
      }
      // Logger.printLog('handleRelativeUrl: baseUrl+url: $baseUrl + $url');
      return Uri.parse(baseUrl).resolve(url).toString();
    } catch (e) {
      Logger.printLog('handleRelativeUrl: baseUrl+url: $baseUrl + $url $e');
      return baseUrl + url;
    }
  }

// Main parsing function
  static Future<(String?, UrlMetaData?)> getWebsiteMetaData(String url) async {
    final htmlContent = await fetchWebpageContent(url);

    if (htmlContent == null) {
      return (null, null);
    }

    // final directory = await getApplicationDocumentsDirectory()..path;
    // await File('htmlContent.html').writeAsString(htmlContent);

    final document = html_parser.parse(htmlContent);
    final metaData = <String, dynamic>{};

    metaData['title'] = extractTitle(document);
    metaData['description'] = extractDescription(document);
    metaData['websiteName'] = extractWebsiteName(document);

    var websiteLogoUrl = extractWebsiteLogoUrl(document);

    if (websiteLogoUrl != null) {
      websiteLogoUrl = handleRelativeUrl(websiteLogoUrl, url);
      metaData['favicon_url'] = websiteLogoUrl;
      // Logger.printLog('logoUrl : $websiteLogoUrl');
      final faviconUint = await fetchImageAsUint8List(
        websiteLogoUrl,
        maxSize: 100000,
      );
      if (faviconUint != null) {
        metaData['favicon'] = StringUtils.convertUint8ListToBase64(faviconUint);
      }
    }

    var imageUrl = extractImageUrl(document);
    Logger.printLog('imageUrl : $imageUrl');
    if (imageUrl != null) {
      imageUrl = handleRelativeUrl(imageUrl, url);
      metaData['banner_image_url'] = imageUrl;
      final bannerImage = await fetchImageAsUint8List(
        imageUrl,
        maxSize: 150000,
      );

      if (bannerImage != null) {
        metaData['banner_image'] =
            StringUtils.convertUint8ListToBase64(bannerImage);
      }
    }

    // Fetch image as Uint8List
    final metaDataObject = UrlMetaData.fromJson(metaData);

    return (htmlContent, metaDataObject);
  }
}
