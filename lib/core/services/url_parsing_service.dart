import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// Minimal URL preview extraction used for URL create/edit autofill.
///
/// This is a simplified port of the legacy implementation from `lib_old/`
/// focused on the fields currently needed by `lv_urls`:
/// - title
/// - description (notes)
/// - thumbnail/banner image (stored as `lv_urls.thumbnail_url` via `Item.imageUrl`)
class UrlPreview {
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? websiteName;
  final String? faviconUrl;

  const UrlPreview({
    this.title,
    this.description,
    this.thumbnailUrl,
    this.websiteName,
    this.faviconUrl,
  });
}

class UrlParsingService {
  static final Map<String, UrlPreview> _previewCache = <String, UrlPreview>{};
  static final Map<String, Future<UrlPreview?>> _inFlight =
      <String, Future<UrlPreview?>>{};

  static Future<String?> fetchWebpageContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body;
      }
      return null;
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? extractTitle(Document document) {
    final ogTitle =
        document.querySelector('meta[property="og:title"]')?.attributes['content'];
    if (ogTitle != null && ogTitle.isNotEmpty) return ogTitle;

    final twitterTitle =
        document.querySelector('meta[name="twitter:title"]')?.attributes['content'];
    if (twitterTitle != null && twitterTitle.isNotEmpty) return twitterTitle;

    return document.querySelector('title')?.text.trim();
  }

  static String? extractDescription(Document document) {
    final metaDescription =
        document.querySelector('meta[name="description"]')?.attributes['content'];
    if (metaDescription != null && metaDescription.isNotEmpty) {
      return metaDescription.trim();
    }

    final ogDescription =
        document.querySelector('meta[property="og:description"]')?.attributes['content'];
    if (ogDescription != null && ogDescription.isNotEmpty) {
      return ogDescription.trim();
    }

    final twitterDescription =
        document.querySelector('meta[name="twitter:description"]')?.attributes['content'];
    if (twitterDescription != null && twitterDescription.isNotEmpty) {
      return twitterDescription.trim();
    }

    return null;
  }

  static String? extractThumbnailUrl(Document document, {required String baseUrl}) {
    final candidates = [
      'meta[property="og:image"]',
      'meta[name="twitter:image"]',
      'meta[itemprop="image"]',
    ];

    for (final selector in candidates) {
      final element = document.querySelector(selector);
      final url = element?.attributes['content'];
      if (url != null && url.isNotEmpty) {
        return _handleRelativeUrl(url, baseUrl);
      }
    }

    return null;
  }

  static String? extractWebsiteName(Document document, {required String baseUrl}) {
    final ogSiteName = document
        .querySelector('meta[property="og:site_name"]')
        ?.attributes['content'];
    if (ogSiteName != null && ogSiteName.trim().isNotEmpty) {
      return ogSiteName.trim();
    }
    return _extractWebsiteNameFromUrl(baseUrl);
  }

  static String? extractFaviconUrl(Document document, {required String baseUrl}) {
    final selectors = [
      'link[rel="icon"]',
      'link[rel="shortcut icon"]',
      'link[rel="apple-touch-icon"]',
      'link[rel="apple-touch-icon-precomposed"]',
      'link[rel="mask-icon"]',
      'meta[itemprop="image"]',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      final href = element?.attributes['href'] ?? element?.attributes['content'];
      if (href != null && href.trim().isNotEmpty) {
        return _handleRelativeUrl(href.trim(), baseUrl);
      }
    }

    return _googleFaviconUrl(baseUrl);
  }

  static String _googleFaviconUrl(String normalizedUrl) {
    return 'https://www.google.com/s2/favicons?sz=64&domain_url=$normalizedUrl';
  }

  static String _extractWebsiteNameFromUrl(String url) {
    try {
      final host = Uri.parse(url).host;
      var normalized = host.startsWith('www.') ? host.substring(4) : host;
      final parts = normalized.split('.');
      if (parts.length >= 2) {
        normalized = parts[parts.length - 2];
      }
      if (normalized.isEmpty) return host;
      return normalized[0].toUpperCase() + normalized.substring(1);
    } catch (_) {
      return '';
    }
  }

  static String _handleRelativeUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (baseUrl.isEmpty) return url;
    try {
      return Uri.parse(baseUrl).resolve(url).toString();
    } catch (_) {
      return url;
    }
  }

  static String _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Assume https for non-schemed inputs like "example.com/path".
    return 'https://$trimmed';
  }

  static Future<UrlPreview?> extractPreview(String rawUrl) async {
    final normalizedUrl = _normalizeUrl(rawUrl);
    if (normalizedUrl.isEmpty) return null;

    final cached = _previewCache[normalizedUrl];
    if (cached != null) return cached;

    final inflight = _inFlight[normalizedUrl];
    if (inflight != null) {
      return inflight;
    }

    final future = _extractPreviewInternal(normalizedUrl);
    _inFlight[normalizedUrl] = future;

    final preview = await future;
    _inFlight.remove(normalizedUrl);
    if (preview != null) {
      _previewCache[normalizedUrl] = preview;
    }
    return preview;
  }

  static Future<UrlPreview?> _extractPreviewInternal(String normalizedUrl) async {
    final html = await fetchWebpageContent(normalizedUrl);
    if (html == null) return null;

    final document = html_parser.parse(html);
    final title = extractTitle(document);
    final description = extractDescription(document);
    final thumbnailUrl = extractThumbnailUrl(document, baseUrl: normalizedUrl);
    final websiteName = extractWebsiteName(document, baseUrl: normalizedUrl);
    final faviconUrl = extractFaviconUrl(document, baseUrl: normalizedUrl);

    return UrlPreview(
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      websiteName: websiteName,
      faviconUrl: faviconUrl,
    );
  }
}

