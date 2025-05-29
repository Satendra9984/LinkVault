// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/src/common/repository_layer/models/url_model.dart';

part 'url_model_offline.g.dart';

@Collection()
class UrlModelOffline {
  UrlModelOffline({
    required this.firestoreId,
    required this.jsonData,
    required this.title,
    required this.url,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavourite,
    this.id,
  });

  factory UrlModelOffline.fromUrlModel(UrlModel urlModel) {
    return UrlModelOffline(
      firestoreId: urlModel.firestoreId,
      jsonData: jsonEncode(urlModel.toJson()),
      url: urlModel.url,
      title: urlModel.title,
      tag: urlModel.tag,
      createdAt: urlModel.createdAt,
      updatedAt: urlModel.updatedAt,
      isFavourite: urlModel.isFavourite,
    );
  }

  final Id? id;

  @Index()
  final String firestoreId;

  // urlmodel json data
  final String jsonData;

  @Index()
  final String? url;

  @Index()
  final String? title; // Indexed field

  @Index()
  final String? tag; // Indexed field

  @Index()
  final DateTime? createdAt; // Indexed field

  @Index()
  final DateTime? updatedAt; // Indexed field

  @Index()
  final bool? isFavourite;

  UrlModelOffline copyWith({
    String? firestoreId,
    UrlModel? urlModel,
  }) {
    return UrlModelOffline(
      id: id,
      firestoreId: firestoreId ?? this.firestoreId,
      jsonData: urlModel != null ? jsonEncode(urlModel.toJson()) : jsonData,
      title: urlModel?.title ?? title,
      url: urlModel?.url ?? url,
      tag: urlModel?.tag ?? tag,
      createdAt: urlModel?.createdAt ?? createdAt,
      updatedAt: urlModel?.updatedAt ?? updatedAt,
      isFavourite: urlModel?.isFavourite ?? isFavourite,
    );
  }

  UrlModel toUrlModel() {
    return UrlModel.fromJson(jsonDecode(jsonData) as Map<String, dynamic>);
  }
}
