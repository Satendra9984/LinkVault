// ignore_for_file: public_member_api_docs

import 'package:link_vault/core/common/repository_layer/models/url_meta_data.dart';

class UrlModel {
  UrlModel({
    required this.firestoreId,
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
    this.parentUrlModelFirestoreId, // New field for linking to parent
    this.settings, // New field for storing additional settings
  });

  factory UrlModel.fromJson(Map<String, dynamic> json) {
    return UrlModel(
      firestoreId: json['id'] as String,
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
      parentUrlModelFirestoreId: json['parent_url_model_id']
          as String?, // Nullable for backward compatibility
      settings:
          json['settings'] as Map<String, dynamic>?, // Nullable settings map
    );
  }

  final String firestoreId;
  final String collectionId;
  final String url;
  final String title;
  final String? description;
  final String tag;
  final bool isFavourite;
  final UrlMetaData? metaData;
  final bool isOffline;
  final String? htmlContent;
  final DateTime createdAt;
  final DateTime updatedAt;

  // V2
  final String? parentUrlModelFirestoreId; // New field for linking to parent
  final Map<String, dynamic>? settings; // New settings field

  Map<String, dynamic> toJson() {
    return {
      'id': firestoreId,
      'collection_id': collectionId,
      'url': url,
      'title': title,
      'description': description,
      'tag': tag,
      'meta_data': metaData?.toJson(),
      'is_offline': isOffline,
      'html_content': htmlContent,
      'created_at': createdAt.toUtc(),
      'updated_at': updatedAt.toUtc(),
      'is_favourite': isFavourite,
      'parent_url_model_id':
          parentUrlModelFirestoreId, // Include in JSON serialization
      'settings': settings, // Include in JSON serialization
    };
  }

  UrlModel copyWith({
    String? firestoreId,
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
    String? parentUrlModelFirestoreId, // New field for linking to parent
    Map<String, dynamic>? settings, // New settings field
  }) {
    return UrlModel(
      firestoreId: firestoreId ?? this.firestoreId,
      collectionId: collectionId ?? this.collectionId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      isFavourite: isFavourite ?? this.isFavourite,
      tag: tag ?? this.tag,
      metaData: metaData ?? this.metaData,
      isOffline: isOffline ?? this.isOffline,
      htmlContent: htmlContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentUrlModelFirestoreId:
          parentUrlModelFirestoreId ?? this.parentUrlModelFirestoreId,
      settings: settings ?? this.settings,
    );
  }
}

// SOME URL-MODEL CONSTANTS
const urlLaunchType = 'url_view_type';
const feedUrlLaunchType = 'feed_url_view_type';
