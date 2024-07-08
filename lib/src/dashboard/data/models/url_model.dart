// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

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
      htmlContent: json['html_content'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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

  // URL meta_data this will be parsed
  final UrlMetaData? metaData;

  // Offline functionality
  final bool isOffline;
  final String? htmlContent;

  // Metadata
  final String createdAt;
  final String updatedAt;

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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UrlMetaData {
  UrlMetaData({
    required this.favicon,
    required this.bannerImage,
    required this.title,
    required this.description,
    required this.websiteName,
  });

  factory UrlMetaData.fromJson(Map<String, dynamic> json) {
    return UrlMetaData(
      favicon: json['favicon'] as Uint8List?,
      bannerImage: json['banner_image'] as Uint8List?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      websiteName: json['websiteName'] as String?,
    );
  }

  final Uint8List? favicon;
  final Uint8List? bannerImage;
  final String? title;
  final String? websiteName;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'favicon': favicon,
      'banner_image': bannerImage,
      'title': title,
      'description': description,
      'websiteName': websiteName,
    };
  }
}
