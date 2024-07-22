// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

part 'url_model_offline.g.dart';

@Collection()
class UrlModelOffline {

  UrlModelOffline({
    // required this.id,
    required this.firestoreId,
    required this.jsonData,
  });

  factory UrlModelOffline.fromUrlModel(UrlModel urlModel) {
    return UrlModelOffline(
      firestoreId: urlModel.firestoreId,
      jsonData: jsonEncode(urlModel.toJson()),
    );
  }

  
  final Id id = Isar.autoIncrement;

  @Index()
  final String firestoreId;

  // urlmodel json data
  final String jsonData;

  UrlModel toUrlModel() {
    return UrlModel.fromJson(jsonDecode(jsonData) as Map<String, dynamic>);
  }
}
