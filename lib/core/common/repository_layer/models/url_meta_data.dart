import 'dart:convert';
import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:link_vault/core/utils/string_utils.dart';

class UrlMetaData {
  UrlMetaData({
    required this.favicon,
    required this.faviconUrl,
    required this.bannerImage,
    required this.bannerImageUrl,
    required this.title,
    required this.description,
    required this.websiteName,
    required this.rssFeedUrl, // Added rssFeedUrl
  });

  factory UrlMetaData.isEmpty({
    required String title,
    String? description,
    String? websiteName,
    Uint8List? favicon,
    String? faviconUrl,
    Uint8List? bannerImage,
    String? bannerImageUrl,
    String? rssFeedUrl, // Added rssFeedUrl
  }) {
    return UrlMetaData(
      favicon: favicon,
      faviconUrl: faviconUrl,
      bannerImage: bannerImage,
      bannerImageUrl: bannerImageUrl,
      title: title,
      description: description,
      websiteName: websiteName,
      rssFeedUrl: rssFeedUrl, // Added rssFeedUrl
    );
  }

  factory UrlMetaData.fromJson(Map<String, dynamic> json) {
    return UrlMetaData(
      favicon: StringUtils.convertBase64ToUint8List(json['favicon'] as String?),
      faviconUrl: json['favicon_url'] as String?,
      bannerImage:
          StringUtils.convertBase64ToUint8List(json['banner_image'] as String?),
      bannerImageUrl: json['banner_image_url'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      websiteName: json['websiteName'] as String?,
      rssFeedUrl: json['rss_feed_url'] as String?, // Added rssFeedUrl
    );
  }

  /// Create an instance from an encoded JSON string
  factory UrlMetaData.fromJsonEncodedString(String jsonString) {
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return UrlMetaData.fromJson(json);
  }

  final Uint8List? favicon;
  final String? faviconUrl;
  final Uint8List? bannerImage;
  final String? bannerImageUrl;
  final String? title;
  final String? description;
  final String? websiteName;
  final String? rssFeedUrl; // Added rssFeedUrl

  Map<String, dynamic> toJson() {
    return {
      'favicon': StringUtils.convertUint8ListToBase64(favicon),
      'favicon_url': faviconUrl,
      'banner_image': StringUtils.convertUint8ListToBase64(bannerImage),
      'banner_image_url': bannerImageUrl,
      'title': title,
      'description': description,
      'websiteName': websiteName,
      'rss_feed_url': rssFeedUrl, // Added rssFeedUrl
    };
  }

  /// Convert the object to an encoded JSON string
  String toJsonEncodedString() {
    final json = toJson();
    return jsonEncode(json);
  }

  UrlMetaData copyWith({
    Uint8List? favicon,
    String? faviconUrl,
    Uint8List? bannerImage,
    String? bannerImageUrl,
    String? title,
    String? description,
    String? websiteName,
    String? rssFeedUrl, // Added rssFeedUrl
  }) {
    return UrlMetaData(
      favicon: favicon ?? this.favicon,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      bannerImage: bannerImage ?? this.bannerImage,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      websiteName: websiteName ?? this.websiteName,
      rssFeedUrl: rssFeedUrl ?? this.rssFeedUrl, // Added rssFeedUrl
    );
  }
}
