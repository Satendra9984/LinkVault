// ignore_for_file: public_member_api_docs

import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

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
          final width = int.tryParse(img.attributes['width'] ?? '1') ?? 1;
          final height = int.tryParse(img.attributes['height'] ?? '1') ?? 1;
          final area = width * height;
          // final aspectRatio = width ~/ height;

          // Logger.printLog('img: ${img.attributes}, area: $area');

          if (area >= minBannerArea &&
                  (width >= minBannerWidth || height >= minBannerHeight)
              // &&
              // (aspectRatio >= 1.5 && aspectRatio <= 6)

              ) {
            final containesLogoAlt =
                (img.attributes['alt'] ?? '').toLowerCase().contains('logo');

            final containesLogoClass =
                (img.attributes['class'] ?? '').toLowerCase().contains('logo');

            if (containesLogoAlt || containesLogoClass) continue;
            final containesAuthorAlt =
                (img.attributes['alt'] ?? '').toLowerCase().contains('author');

            final containesAuthorClass = (img.attributes['class'] ?? '')
                .toLowerCase()
                .contains('author');
            if (containesAuthorAlt || containesAuthorClass) continue;

            largestImageElement = img;
            break;
          }
        }

        // Logger.printLog(
        //     'after loop: ${largestImageElement?.attributes['src']}');
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

  static String getWebsiteLogoUrl(String url) {
    return 'https://www.google.com/s2/favicons?sz=64&domain_url=$url';
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
          if (href != null && _isSupportedImageType(href)) {
            return href;
          }
        }
      }

      // Fallback: try to find favicon in the root directory
      // final fallbackUrl = '/assets/img/favicons.png';

      return null;
    } catch (e) {
      Logger.printLog('error in "extractWebsiteLogoUrl" $e');
      return null;
    }
  }

  static bool _isSupportedImageType(String url) {
    final supportedExtensions = ['png', 'jpeg', 'jpg', 'gif'];
    final extension = url.split('.').last.toLowerCase();
    return supportedExtensions.contains(extension);
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

// Function to fetch image as Uint8List
  static Future<Uint8List?> fetchImageAsUint8List(
    String imageUrl, {
    required int maxSize,
    required bool compressImage,
    required int quality,
    bool? autofillPng,
    (int r, int g, int b)? autofillColor,
  }) async {
    try {
      // Logger.printLog('websiteImageUrl: $imageUrl');
      if (imageUrl.isEmpty) return null;
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final originalImageBytes = response.bodyBytes;
        // return originalImageBytes;
        // Logger.printLog(
        //   '[parsing][original] : $imageUrl, ${originalImageBytes.length}',
        // );
        if (!compressImage) return originalImageBytes;
        final compressedImage = await compressImageAsUint8List(
          originalImageBytes,
          maxSize: maxSize,
          quality: quality,
          autofillPng: autofillPng,
          autofillColor: autofillColor,
        );
        // Logger.printLog(
        //   '[parsing][compressed] : $imageUrl, ${compressedImage?.length}',
        // );
        return compressedImage;
      }
      return null;
    } catch (e) {
      Logger.printLog('error in "fetchImageAsUint8List" $e');
      return null;
    }
  }

  static Future<Uint8List?> compressImageAsUint8List(
    Uint8List originalImageBytes, {
    required int maxSize,
    required int quality,
    required bool? autofillPng,
    (int r, int g, int b)? autofillColor,
  }) async {
    try {
      // Logger.printLog('websiteImageUrl: $imageUrl');
      final compressedImage = await ImageUtils.compressImage(
        originalImageBytes,
        quality: quality,
        autofillPng: autofillPng ?? false,
        autofillColor: autofillColor,
      );

      return compressedImage;
    } catch (e) {
      Logger.printLog('error in "fetchImageAsUint8List" $e');
      return null;
    }
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
      Logger.printLog('handleRelativeUrl: $e');
      return baseUrl + url;
    }
  }

// Main parsing function
  static Future<(String?, UrlMetaData?)> getWebsiteMetaData(String url) async {
    final htmlContent = await fetchWebpageContent(url);
    final metaData = <String, dynamic>{};

    if (htmlContent == null) {
      metaData['websiteName'] = extractWebsiteNameFromUrlString(url);
      final websiteLogoUrl = getWebsiteLogoUrl(url);
      metaData['favicon_url'] = websiteLogoUrl;

      return (null, UrlMetaData.fromJson(metaData));
    }

    final document = html_parser.parse(htmlContent);

    metaData['title'] = extractTitle(document);
    metaData['description'] = extractDescription(document);
    metaData['websiteName'] =
        extractWebsiteName(document) ?? extractWebsiteNameFromUrlString(url);

    var websiteLogoUrl = extractWebsiteLogoUrl(document);
    websiteLogoUrl ??= getWebsiteLogoUrl(url);
    websiteLogoUrl = handleRelativeUrl(websiteLogoUrl, url);
    metaData['favicon_url'] = websiteLogoUrl;
    final faviconUint = await fetchImageAsUint8List(
      websiteLogoUrl,
      maxSize: 100000,
      compressImage: true,
      quality: 80,
      autofillPng: true,
    );
    // Logger.printLog(
    //   '[parsing][favicon][80] : $websiteLogoUrl, ${faviconUint?.length}',
    // );
    if (faviconUint != null) {
      metaData['favicon'] = StringUtils.convertUint8ListToBase64(faviconUint);
    }

    var imageUrl = extractImageUrl(document) ?? websiteLogoUrl;
    // Logger.printLog('imageUrl : $imageUrl');
    if (imageUrl != null) {
      imageUrl = handleRelativeUrl(imageUrl, url);
      metaData['banner_image_url'] = imageUrl;
      final bannerImage = await fetchImageAsUint8List(
        imageUrl,
        maxSize: 150000,
        compressImage: true,
        quality: 75,
        autofillPng: false,
      );
      // Logger.printLog(
      //   '[parsing][banner][75] : $imageUrl, ${bannerImage?.length}',
      // );
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
