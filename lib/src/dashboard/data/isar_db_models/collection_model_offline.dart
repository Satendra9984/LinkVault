// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:isar/isar.dart';

import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

// Ensure that this is properly imported if using any generated files
part 'collection_model_offline.g.dart';

@Collection()
class CollectionModelOffline {
  CollectionModelOffline({
    required this.firestoreId,
    required this.jsonData,
    this.id,
  });

  factory CollectionModelOffline.fromCollectionModel(
    CollectionModel collectionModel,
  ) {
    return CollectionModelOffline(
      // Convert Firestore ID to an integer if possible
      firestoreId: collectionModel.id,
      jsonData: jsonEncode(collectionModel.toJson()),
    );
  }
  final Id? id;

  @Index()
  final String firestoreId; // This is the Firestore ID

  final String jsonData; // The JSON data to store

  CollectionModelOffline copyWith({
    String? firestoreId,
    CollectionModel? collectionModel,
  }) {
    return CollectionModelOffline(
      id: id,
      firestoreId: firestoreId ?? this.firestoreId,
      jsonData: collectionModel != null ? jsonEncode(collectionModel.toJson()) : jsonData,
    );
  }

  CollectionModel toCollectionModel() {
    return CollectionModel.fromJson(
      jsonDecode(jsonData) as Map<String, dynamic>,
    );
  }
}
