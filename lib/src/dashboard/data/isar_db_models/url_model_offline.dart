// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

part 'url_model_offline.g.dart';

@Collection()
class UrlModelOffline {
  UrlModelOffline({
    required this.firestoreId,
    required this.jsonData,
    this.id,
  });

  factory UrlModelOffline.fromUrlModel(UrlModel urlModel) {
    return UrlModelOffline(
      firestoreId: urlModel.firestoreId,
      jsonData: jsonEncode(urlModel.toJson()),
    );
  }

  final Id? id;

  @Index()
  final String firestoreId;

  // urlmodel json data
  final String jsonData;

  UrlModelOffline copyWith({
    String? firestoreId,
    UrlModel? urlModel,
  }) {
    return UrlModelOffline(
      id: id,
      firestoreId: firestoreId ?? this.firestoreId,
      jsonData: urlModel != null ? jsonEncode(urlModel.toJson()) : jsonData,
    );
  }

  UrlModel toUrlModel() {
    return UrlModel.fromJson(jsonDecode(jsonData) as Map<String, dynamic>);
  }
}
