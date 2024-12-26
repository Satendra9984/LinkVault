// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/repository_layer/models/url_meta_data.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';

part 'url_model_isar.g.dart';

@Collection()
class UrlModelIsar {
  UrlModelIsar({
    this.id,
    required this.firestoreId,
    required this.collectionId,
    required this.url,
    required this.title,
    this.description,
    required this.tag,
    this.metaData,
    required this.isOffline,
    this.htmlContent,
    required this.isFavourite,
    required this.createdAt,
    required this.updatedAt,
    this.parentUrlModelFirestoreId,
    this.settings,
  });

  /// Create from `UrlModel`
  factory UrlModelIsar.fromUrlModel(UrlModel model) {
    return UrlModelIsar(
      firestoreId: model.firestoreId,
      collectionId: model.collectionId,
      url: model.url,
      title: model.title,
      description: model.description,
      tag: model.tag,
      isFavourite: model.isFavourite,
      metaData: model.metaData?.toJsonEncodedString(),
      isOffline: model.isOffline,
      htmlContent: model.htmlContent,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      parentUrlModelFirestoreId: model.parentUrlModelFirestoreId,
      settings: model.settings != null ? jsonEncode(model.settings) : null,
    );
  }

  /// Create from JSON (UrlModel's JSON structure)
  factory UrlModelIsar.fromJson(Map<String, dynamic> json) {
    return UrlModelIsar(
      firestoreId: json['id'] as String,
      collectionId: json['collection_id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tag: json['tag'] as String,
      isFavourite: (json['is_favourite'] as bool?) ?? false,
      metaData: json['meta_data'] != null
          ? jsonEncode(json['meta_data'] as Map<String, dynamic>)
          : null,
      isOffline: json['is_offline'] as bool,
      htmlContent: json['html_content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentUrlModelFirestoreId: json['parent_url_model_id'] as String?,
      settings: json['settings'] != null ? jsonEncode(json['settings']) : null,
    );
  }

  /// Copy properties from UrlModel
  UrlModelIsar copyWithUrlModel(UrlModel model) {
    return copyWith(
      id: id,
      firestoreId: model.firestoreId,
      collectionId: model.collectionId,
      url: model.url,
      title: model.title,
      description: model.description,
      tag: model.tag,
      metaData: model.metaData?.toJsonEncodedString(),
      isOffline: model.isOffline,
      htmlContent: model.htmlContent,
      isFavourite: model.isFavourite,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      parentUrlModelFirestoreId: model.parentUrlModelFirestoreId,
      settings: model.settings != null ? jsonEncode(model.settings) : null,
    );
  }

  /// Copy with optional updated properties
  UrlModelIsar copyWith({
    Id? id,
    String? firestoreId,
    String? collectionId,
    String? url,
    String? title,
    String? description,
    String? tag,
    String? metaData,
    bool? isOffline,
    String? htmlContent,
    bool? isFavourite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentUrlModelFirestoreId,
    String? settings,
  }) {
    return UrlModelIsar(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      collectionId: collectionId ?? this.collectionId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      metaData: metaData ?? this.metaData,
      isOffline: isOffline ?? this.isOffline,
      htmlContent: htmlContent ?? this.htmlContent,
      isFavourite: isFavourite ?? this.isFavourite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentUrlModelFirestoreId:
          parentUrlModelFirestoreId ?? this.parentUrlModelFirestoreId,
      settings: settings ?? this.settings,
    );
  }

  @Index()
  final Id? id;

  @Index()
  final String firestoreId;

  @Index()
  final String collectionId;

  @Index()
  final String url;

  @Index()
  final String title;

  final String? description;

  @Index()
  final String tag;

  final String? metaData;

  @Index()
  final bool isOffline;

  final String? htmlContent;

  @Index()
  final bool isFavourite;

  @Index()
  final DateTime createdAt;

  @Index()
  final DateTime updatedAt;

  final String? parentUrlModelFirestoreId;

  final String? settings;

  /// Convert back to `UrlModel`
  UrlModel toUrlModel() {
    return UrlModel(
      firestoreId: firestoreId,
      collectionId: collectionId,
      url: url,
      title: title,
      description: description,
      tag: tag,
      isFavourite: isFavourite,
      metaData: metaData != null
          ? UrlMetaData.fromJsonEncodedString(metaData!)
          : null,
      isOffline: isOffline,
      htmlContent: htmlContent,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parentUrlModelFirestoreId: parentUrlModelFirestoreId,
      settings: (settings != null ? jsonDecode(settings!) : null)
          as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firestore_id': firestoreId,
      'collection_id': collectionId,
      'url': url,
      'title': title,
      'description': description,
      'tag': tag,
      'meta_data': (settings != null ? jsonDecode(settings!) : null),
      'is_offline': isOffline,
      'html_content': htmlContent,
      'is_favourite': isFavourite,
      'created_at': createdAt.toUtc(),
      'updated_at': updatedAt.toUtc(),
      'parent_url_model_id': parentUrlModelFirestoreId,
      'settings': settings != null ? jsonDecode(settings!) : null,
    };
  }
}
