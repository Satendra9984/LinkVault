// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:link_vault/core/utils/string_utils.dart';

class UrlModel {
  UrlModel({
    required this.id,
    required this.collectionId,
    required this.url,
    required this.title,
    required this.tag,
    required this.isOffline,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavourite,
    this.metaData,
    this.description,
    this.htmlContent,
  });

  factory UrlModel.fromJson(Map<String, dynamic> json) {
    return UrlModel(
      id: json['id'] as String,
      collectionId: json['collection_id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tag: json['tag'] as String,
      metaData: UrlMetaData.fromJson(
        json['meta_data'] as Map<String, dynamic>? ?? {},
      ),
      isOffline: json['is_offline'] as bool,
      isFavourite: (json['is_favourite'] as bool?) ?? false,
      htmlContent: json['html_content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // these data are for the user
  final String id;
  final String collectionId;
  // User filled data
  final String url;
  final String title;
  final String? description;
  final String tag;
  final bool isFavourite;
  // URL meta_data this will be parsed
  final UrlMetaData? metaData;

  // Offline functionality
  final bool isOffline;
  final String? htmlContent;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_id': collectionId,
      'url': url,
      'title': title,
      'description': description,
      'tag': tag,
      'meta_data': metaData?.toJson(),
      'is_offline': isOffline,
      'html_content': htmlContent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favourite' : isFavourite,
    };
  }

  UrlModel copyWith({
    String? id,
    String? collectionId,
    String? url,
    String? title,
    String? description,
    bool? isFavourite,
    String? tag,
    UrlMetaData? metaData,
    bool? isOffline,
    String? htmlContent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UrlModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      isFavourite: isFavourite ?? this.isFavourite,
      tag: tag ?? this.tag,
      metaData: metaData ?? this.metaData,
      isOffline: isOffline ?? this.isOffline,
      htmlContent: htmlContent ?? this.htmlContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // bool get isEmpty {
  //   return id.isEmpty &&
  //          collectionId.isEmpty &&
  //          url.isEmpty &&
  //          title.isEmpty &&
  //          (description == null || description!.isEmpty) &&
  //          tag.isEmpty &&
  //          (metaData == null || metaData!.isEmpty) &&
  //          (htmlContent == null || htmlContent!.isEmpty) &&
  //          createdAt.isEmpty &&
  //          updatedAt.isEmpty;
  // }
}

class UrlMetaData {
  UrlMetaData({
    required this.favicon,
    required this.faviconUrl,
    required this.bannerImage,
    required this.bannerImageUrl,
    required this.title,
    required this.description,
    required this.websiteName,
  });

  factory UrlMetaData.isEmpty({
    required String title,
    String? description,
    String? websiteName,
    Uint8List? favicon,
    String? faviconUrl,
    Uint8List? bannerImage,
    String? bannerImageUrl,
  }) {
    return UrlMetaData(
      favicon: favicon,
      faviconUrl: faviconUrl,
      bannerImage: bannerImage,
      bannerImageUrl: bannerImageUrl,
      title: title,
      description: description,
      websiteName: websiteName,
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
    );
  }

  final Uint8List? favicon;
  final String? faviconUrl;
  final Uint8List? bannerImage;
  final String? bannerImageUrl;
  final String? title;
  final String? description;
  final String? websiteName;

  Map<String, dynamic> toJson() {
    return {
      'favicon': StringUtils.convertUint8ListToBase64(favicon),
      'favicon_url': faviconUrl,
      'banner_image': StringUtils.convertUint8ListToBase64(bannerImage),
      'banner_image_url': bannerImageUrl,
      'title': title,
      'description': description,
      'websiteName': websiteName,
    };
  }

  UrlMetaData copyWith({
    Uint8List? favicon,
    String? faviconUrl,
    Uint8List? bannerImage,
    String? bannerImageUrl,
    String? title,
    String? description,
    String? websiteName,
  }) {
    return UrlMetaData(
      favicon: favicon ?? this.favicon,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      bannerImage: bannerImage ?? this.bannerImage,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      websiteName: websiteName ?? this.websiteName,
    );
  }

  // static Uint8List? convertToUint8List(dynamic data) {
  //   if (data is List<dynamic>) {
  //     return Uint8List.fromList(data.map((item) => item as int).toList());
  //   }
  //   return null;
  // }
}
