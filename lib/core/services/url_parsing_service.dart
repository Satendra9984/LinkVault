// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';

class UrlParsingService {
  // DOWNLOAD THE HTML-DATA FROM WEBPAGE URL
  static Future<String?> fetchWebpageContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        // // Logger.printLog('error in "fetchWebpageContent" statuscode error');
        return null;
      }
    } catch (e) {
      // // Logger.printLog('error in "fetchWebpageContent" $e');
      return null;
    }
  }

  // EXTRACT TITLE FROM WEBPAGE HTML DOCUMENT
  static String? extractTitle(Document document) {
    final title = document.head?.querySelector('title')?.text;

    if (title == null) return null;

    // // Logger.printLog('title: $title');
    return StringUtils.getUnicodeString(title);
  }

  // EXTRACT DESCRIPTION FROM WEBPAGE HTML DOCUMENT
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
      // // Logger.printLog('error in "extractDescription" $e');
      return null;
    }
  }

  // EXTRACTS WEBSITE NAME IN THE HTML-DOCUMENT OF WBPAGE
  static String? extractWebsiteName(Document document) {
    try {
      final websiteName = document.head
          ?.querySelector('meta[property="og:site_name"]')
          ?.attributes['content'];

      return websiteName;
    } catch (e) {
      // Logger.printLog('error in "extractWebsiteName" $e');

      return null;
    }
  }

  // EXTRACTS WEBSITE NAME IN THE URL-STRING OF WBPAGE
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

  // EXTRACTS BANNER IMAGE-URLS FROM THE HTML DOCUMENT OF WEBPAGE
  static String? extractImageUrl(Document document) {
    try {
      // First, try to find banner image from meta tags
      final metaImageUrl = _extractMetaImageUrl(document);
      if (metaImageUrl != null) {
        return metaImageUrl;
      }

      // If meta tags don't provide a suitable image, search in the body
      return _extractBodyImageUrl(document);
    } catch (e) {
      // // Logger.printLog('Error in "extractImageUrl": $e');
      return null;
    }
  }

  static String? _extractMetaImageUrl(Document document) {
    final metaTags = [
      'meta[property="og:image"]',
      'meta[name="twitter:image"]',
      'meta[itemprop="image"]',
    ];

    for (final metaTag in metaTags) {
      final element = document.head?.querySelector(metaTag);
      if (element != null && element.attributes['content'] != null) {
        final imageUrl = element.attributes['content']!.toLowerCase();
        if (!_isLikelyFaviconOrLogo(imageUrl)) {
          return element.attributes['content'];
        }
      }
    }

    return null;
  }

  static List<String>? _extractMetaImageUrList(Document document) {
    final images = <String>[];
    final metaTags = [
      'meta[property="og:image"]',
      'meta[name="twitter:image"]',
      'meta[itemprop="image"]',
    ];

    for (final metaTag in metaTags) {
      final element = document.head?.querySelector(metaTag);
      if (element != null && element.attributes['content'] != null) {
        final imageUrl = element.attributes['content']!.toLowerCase();
        if (!_isLikelyFaviconOrLogo(imageUrl)) {
          final imageurl = element.attributes['content'];
          if (imageurl != null) {
            images.add(imageUrl);
          }
        }
      }
    }

    return images;
  }

  static String? _extractBodyImageUrl(Document document) {
    final imageElements = document.body?.querySelectorAll('img');
    if (imageElements == null || imageElements.isEmpty) {
      return null;
    }

    const minBannerArea = 90000;
    const minBannerWidth = 600;
    const minBannerHeight = 150;

    Element? bestCandidate;
    var maxArea = 0;

    for (final img in imageElements) {
      final width = int.tryParse(img.attributes['width'] ?? '') ?? 0;
      final height = int.tryParse(img.attributes['height'] ?? '') ?? 0;
      final src = img.attributes['src'];

      if (src == null || _isLikelyFaviconOrLogo(src)) {
        continue;
      }

      // If width and height are not specified in attributes, try to get from style
      final computedWidth = width > 0
          ? width
          : _extractDimensionFromStyle(img.attributes['style'], 'width');
      final computedHeight = height > 0
          ? height
          : _extractDimensionFromStyle(img.attributes['style'], 'height');

      final area = computedWidth * computedHeight;

      if (area >= minBannerArea &&
          (computedWidth >= minBannerWidth ||
              computedHeight >= minBannerHeight) &&
          !_containsUnwantedKeywords(img) &&
          area > maxArea) {
        bestCandidate = img;
        maxArea = area;
      }
    }

    return bestCandidate?.attributes['src'];
  }

  static List<String>? _extractBodyImageUrlList(Document document) {
    final images = <String>[];

    final imageElements = document.body?.querySelectorAll('img');
    if (imageElements == null || imageElements.isEmpty) {
      return null;
    }

    const minBannerArea = 90000;
    const minBannerWidth = 600;
    const minBannerHeight = 150;

    Element? bestCandidate;
    var maxArea = 0;

    for (final img in imageElements) {
      final width = int.tryParse(img.attributes['width'] ?? '') ?? 0;
      final height = int.tryParse(img.attributes['height'] ?? '') ?? 0;
      final src = img.attributes['src'];

      if (src == null || _isLikelyFaviconOrLogo(src)) {
        continue;
      }

      // If width and height are not specified in attributes, try to get from style
      final computedWidth = width > 0
          ? width
          : _extractDimensionFromStyle(img.attributes['style'], 'width');
      final computedHeight = height > 0
          ? height
          : _extractDimensionFromStyle(img.attributes['style'], 'height');

      final area = computedWidth * computedHeight;

      if (area >= minBannerArea &&
          (computedWidth >= minBannerWidth ||
              computedHeight >= minBannerHeight) &&
          !_containsUnwantedKeywords(img) &&
          area > maxArea) {
        bestCandidate = img;
        if (img.attributes['src'] != null) {
          images.add(img.attributes['src'].toString());
        }
        maxArea = area;
      }
    }

    // return bestCandidate?.attributes['src'];
    return images;
  }

  static bool _isLikelyFaviconOrLogo(String url) {
    final lowercaseUrl = url.toLowerCase();
    return lowercaseUrl.contains('favicon') ||
        lowercaseUrl.contains('logo') ||
        lowercaseUrl.endsWith('.ico') ||
        lowercaseUrl.contains('icon');
  }

  static bool _containsUnwantedKeywords(Element img) {
    final alt = (img.attributes['alt'] ?? '').toLowerCase();
    final className = (img.attributes['class'] ?? '').toLowerCase();

    return alt.contains('logo') ||
        className.contains('logo') ||
        alt.contains('author') ||
        className.contains('author');
  }

  static int _extractDimensionFromStyle(String? style, String dimension) {
    if (style == null) return 0;
    final regex = RegExp('$dimension:\\s*(\\d+)px');
    final match = regex.firstMatch(style);
    return match != null ? int.tryParse(match.group(1) ?? '') ?? 0 : 0;
  }

  // TO GET WEBSITE LOGO URL USING GOOGLE HELPER
  static String getWebsiteLogoUrl(String url) {
    return 'https://www.google.com/s2/favicons?sz=64&domain_url=$url';
  }

  // EXTRACTS WEBSITE LOGO IMAGE URL FROM HTML-DOCUMENT OF WEBPAGE
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
      // Logger.printLog('error in "extractWebsiteLogoUrl" $e');
      return null;
    }
  }

  // EXTRACTS ALL LOGO IMAGE URL FROM HTML-DOCUMENT OF WEBPAGE AS A LIST
  static List<String>? extractWebsiteLogoUrlList(Document document) {
    final images = <String>[];
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
            images.add(href);
          }
        }
      }

      // Fallback: try to find favicon in the root directory
      // final fallbackUrl = '/assets/img/favicons.png';
      return images;
    } catch (e) {
      // Logger.printLog('error in "extractWebsiteLogoUrl" $e');
      return images;
    }
  }

  static List<String> getAllImageUrlsAvailable(
    Document? webpagedocument,
    String baseUrl, {
    String? webHtmlContent,
  }) {
    final images = <String>{};

    // try {
    Logger.printLog(
        '${webpagedocument == null}, html ${webHtmlContent == null}');
    if (webpagedocument == null && webHtmlContent == null) {
      return images.toList();
    }
    var document = html_parser.parse('');

    if (webpagedocument != null) {
      document = webpagedocument;
    }

    if (webHtmlContent != null) {
      document = html_parser.parse(webHtmlContent);
    }
    // first get all the favicons
    final favicons =
        extractWebsiteLogoUrlList(document) ?? [getWebsiteLogoUrl(baseUrl)];
    final bannerImages = _extractMetaImageUrList(document) ?? <String>[]
      ..addAll(_extractBodyImageUrlList(document) ?? <String>[]);

    // Regular expression to find URLs ending with common image file extensions
    final urlRegex = RegExp(
      r"https?://[^\s<>\']+?(?:png|jpg|jpeg|gif|bmp|webp|svg)[^\s<>\']*",
      caseSensitive: false,
    );

    final htmlContent = webHtmlContent ?? document.toString();
    // Logger.printLog(webHtmlContent ?? '');
    // Find all matches of the regular expression in the HTML content
    final matches = urlRegex.allMatches(htmlContent);

    // Process each match to ensure the URL is complete
    final imageUrls = <String>[];
//src="https://styles.redditmedia.com/t5_2x3q8/styles/communityIcon_dsw8tf6mg06b1.png"

    for (final match in matches) {
      if (match.group(0) == null) continue;

      final url = match.group(0)!;
      // Logger.printLog('regex: $url');
      imageUrls.add(handleRelativeUrl(url, baseUrl));
    }

    images.addAll([...imageUrls,...bannerImages, ...favicons, ]);
    // } catch (e) {
    //   Logger.printLog('Error gettingAllImages $e');
    // }

    return images.toList();
  }

  // CHECKS IF THE URL CONTAINS ANY IMAGE ELEMENT
  // LIKE [.png, .jped, .jpg, .gif] ANYWHERE IN THE URL
  static bool _isSupportedImageType(String url) {
    final supportedExtensions = ['png', 'jpeg', 'jpg', 'gif'];
    final extension = url.split('.').last.toLowerCase();
    return supportedExtensions.contains(extension);
  }

  // DOWNLOAD THE IMAGE AS UNIT8LIST FROM THE IMAGE URL
  // USUALLY EXTRACTED FROM WEBPAGE
  static Future<Uint8List?> fetchImageAsUint8List(
    String imageUrl, {
    required int maxSize,
    required bool compressImage,
    required int quality,
    bool? autofillPng,
    (int r, int g, int b)? autofillColor,
  }) async {
    try {
      if (imageUrl.isEmpty) return null;
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final originalImageBytes = response.bodyBytes;
        if (!compressImage) return originalImageBytes;
        final compressedImage = await compressImageAsUint8List(
          originalImageBytes,
          maxSize: maxSize,
          quality: quality,
          autofillPng: autofillPng,
          autofillColor: autofillColor,
        );
        return compressedImage;
      }
      return null;
    } catch (e) {
      // Logger.printLog('[urlParser] : error in "fetchImageAsUint8List" $e');
      return null;
    }
  }

  // COMPRESS THE UINT8LIST IMAGE
  static Future<Uint8List?> compressImageAsUint8List(
    Uint8List originalImageBytes, {
    required int maxSize,
    required int quality,
    required bool? autofillPng,
    (int r, int g, int b)? autofillColor,
  }) async {
    try {
      final compressedImage = await ImageUtils.compressImage(
        originalImageBytes,
        quality: quality,
        autofillPng: autofillPng ?? false,
        autofillColor: autofillColor,
      );

      return compressedImage;
    } catch (e) {
      return null;
    }
  }

  // COMPLETE THE EXTRACTED URL FROM HTML WITH BASE URL
  // SOMETIMES EXTRACTED ONES ARE RELATIVE [/assets/images/image.png]
  static String handleRelativeUrl(String url, String baseUrl) {
    try {
      if (url.startsWith('http')) {
        return url;
      }
      // Logger.printLog('handleRelativeUrl: baseUrl+url: $baseUrl + $url');
      return Uri.parse(baseUrl).resolve(url).toString();
    } catch (e) {
      // Logger.printLog('handleRelativeUrl: $e');
      return baseUrl + url;
    }
  }

  // GET ALL THE META-DATA OF THE WEBPAGE
  // LIKE [TITLE, DESCRIPTION, FAVICONURL, BANNERIMAGEURL, DATE ETC.]
  static Future<(String?, UrlMetaData?)> getWebsiteMetaData(
    String url, {
    bool fetchBannerImageUintData = false,
    bool fetchFaviconImageUintData = false,
  }) async {
    final htmlContent = await fetchWebpageContent(url);
    final metaData = <String, dynamic>{};

    if (htmlContent == null) {
      metaData['websiteName'] = extractWebsiteNameFromUrlString(url);
      final websiteLogoUrl = getWebsiteLogoUrl(url);
      metaData['favicon_url'] = websiteLogoUrl;

      return (null, UrlMetaData.fromJson(metaData));
    }

    final document = html_parser.parse(htmlContent);

    // Logger.printLog('[doc] : ${document.toString()}');

    metaData['title'] = extractTitle(document);
    metaData['description'] = extractDescription(document);
    metaData['websiteName'] =
        extractWebsiteName(document) ?? extractWebsiteNameFromUrlString(url);

    var websiteLogoUrl = extractWebsiteLogoUrl(document);
    websiteLogoUrl ??= getWebsiteLogoUrl(url);
    websiteLogoUrl = handleRelativeUrl(websiteLogoUrl, url);
    metaData['favicon_url'] = websiteLogoUrl;

    final faviconUint = fetchBannerImageUintData
        ? await fetchImageAsUint8List(
            websiteLogoUrl,
            maxSize: 100000,
            compressImage: true,
            quality: 80,
            autofillPng: true,
          )
        : null;

    if (faviconUint != null) {
      metaData['favicon'] = StringUtils.convertUint8ListToBase64(faviconUint);
    }

    var imageUrl = extractImageUrl(document);
    // Logger.printLog('imageUrl : $imageUrl');
    if (imageUrl != null && imageUrl != websiteLogoUrl) {
      imageUrl = handleRelativeUrl(imageUrl, url);
      metaData['banner_image_url'] = imageUrl;

      final bannerImage = fetchBannerImageUintData
          ? await fetchImageAsUint8List(
              imageUrl,
              maxSize: 150000,
              compressImage: true,
              quality: 75,
              autofillPng: false,
            )
          : null;
      if (bannerImage != null) {
        metaData['banner_image'] =
            StringUtils.convertUint8ListToBase64(bannerImage);
      }
    }
    // Fetch image as Uint8List
    final metaDataObject = UrlMetaData.fromJson(metaData);

    // Logger.printLog(StringUtils.getJsonFormat(metaDataObject.toJson()));

    return (htmlContent, metaDataObject);
  }

  // EXTRACTS ALL THE RSS-FEED URLS FROM THE HTML DOCUMENT OF THE WEBPAGE
  static String? extractRssFeedUrl(Document document, String baseUrl) {
    try {
      // List of possible RSS feed selectors
      final rssSelectors = [
        'link[type="application/rss+xml"]',
        'link[type="application/atom+xml"]',
        'link[rel="alternate"][type="application/rss+xml"]',
        'link[rel="alternate"][type="application/atom+xml"]',
      ];

      // Loop through the selectors to find the RSS feed link
      for (final selector in rssSelectors) {
        final rssElement = document.head?.querySelector(selector);
        if (rssElement != null) {
          final rssUrl = rssElement.attributes['href'];
          if (rssUrl != null) {
            return rssUrl.startsWith('http')
                ? rssUrl
                : handleRelativeUrl(rssUrl, baseUrl); // Handle relative URLs
          }
        }
      }
      return null;
    } catch (e) {
      // Logger.printLog('error in "extractRssFeedUrl" $e');
      return null;
    }
  }

  /// Fetches the HTML content from a given RSS feed URL, parses it, and attempts to extract the banner image URL.
  ///
  /// This function handles network errors, parsing issues, and unexpected exceptions. It returns `null` if any issue
  /// occurs during the fetching or parsing process, but rethrows network-related exceptions to allow retry mechanisms.
  ///
  /// - [rssFeedUrl]: The URL of the RSS feed whose banner image is to be extracted.
  ///
  /// Returns the banner image URL if extraction is successful, otherwise returns `null`.
  ///
  /// Throws:
  /// - `SocketException`: if there is a network-related issue (e.g., no internet, timeout).
  /// - `HttpException`: if the HTTP request fails (e.g., invalid status code).
  /// - `FormatException`: if the HTML parsing fails.
  /// - Other exceptions are logged and handled gracefully, returning `null`.
  static Future<String?> fetchParseAndExtractBanner(String rssFeedUrl) async {
    try {
      final response = await http.get(Uri.parse(rssFeedUrl));

      if (response.statusCode == 200 || response.body.isNotEmpty) {
        final webPageData = response.body;
        final htmlContent = html_parser.parse(webPageData);
        return UrlParsingService.extractImageUrl(htmlContent);
      } else if (response.statusCode == 404 || response.statusCode == 410) {
        // Permanent errors: return null as no further requests should be made
        // // Logger.printLog(
        //     'Resource not found or gone (404/410). No further attempts.');
        return null;
      } else if (response.statusCode == 500 || response.statusCode == 503) {
        // Temporary errors: rethrow to allow retries
        // // Logger.printLog('Server error (500/503). Retrying might be necessary.');
        throw const HttpException('Temporary server issue. Retry recommended.');
      } else {
        // Other unhandled HTTP status codes: log and return null
        // // Logger.printLog('Unhandled HTTP status code: ${response.statusCode}');
        return null;
      }
    } on SocketException {
      // // Logger.printLog('Network issue in fetchParseAndExtractBanner: $e');
      rethrow; // Allowing retries
    } on HttpException {
      // // Logger.printLog('HTTP issue in fetchParseAndExtractBanner: $e');
      rethrow; // Allowing handling based on HTTP status
    } on FormatException {
      // // Logger.printLog('Parsing issue in fetchParseAndExtractBanner: $e');
      return null; // Parsing failure is final
    } catch (e) {
      // // Logger.printLog(
      // 'Unexpected error in fetchParseAndExtractBanner: $e (${e.runtimeType})');
      return null;
    }
  }
}
