import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';

part 'collection_model_isar.g.dart';

@Collection()
class CollectionModelIsar {
  CollectionModelIsar({
    this.id,
    required this.firestoreId,
    required this.userId,
    required this.parentCollection,
    required this.name,
    required this.category,
    required this.sharedWith,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.subcollectionCount = 0,
    this.urlCount = 0,
    this.icon,
    this.background,
    this.status,
    this.settings,
  });

  factory CollectionModelIsar.fromCollectionModel(
    CollectionModel collectionModel,
  ) {
    return CollectionModelIsar(
      firestoreId: collectionModel.id,
      userId: collectionModel.userId,
      parentCollection: collectionModel.parentCollection,
      name: collectionModel.name,
      description: collectionModel.description,
      category: collectionModel.category,
      subcollectionCount: collectionModel.subcollectionCount,
      urlCount: collectionModel.urlCount,
      icon: collectionModel.icon != null
          ? jsonEncode(collectionModel.icon)
          : null,
      background: collectionModel.background != null
          ? jsonEncode(collectionModel.background)
          : null,
      status: collectionModel.status != null
          ? jsonEncode(collectionModel.status)
          : null,
      sharedWith: collectionModel.sharedWith
          .map(
            (shared) => jsonEncode(shared.toJson()),
          )
          .toList(),
      createdAt: collectionModel.createdAt,
      updatedAt: collectionModel.updatedAt,
      settings: collectionModel.settings != null
          ? jsonEncode(collectionModel.settings)
          : null,
    );
  }

  Id? id;

  @Index()
  late String firestoreId;

  @Index()
  late String userId;

  @Index()
  late String parentCollection;

  @Index()
  late String name;

  String? description;

  @Index()
  late String category;

  // Store both IDs and counts
  // List<String> subcollectionIds = [];

  int? subcollectionCount;

  // List<String> urlIds = [];

  int? urlCount;

  String? icon;
  String? background;
  String? status;
  String? settings;

  List<String> sharedWith = [];

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  CollectionModel toCollectionModel() {
    return CollectionModel(
      id: firestoreId,
      userId: userId,
      parentCollection: parentCollection,
      name: name,
      description: description,
      category: category,
      subcollectionCount: subcollectionCount,
      urlCount: urlCount,
      icon: (icon != null ? jsonDecode(icon!) : null) as Map<String, dynamic>?,
      background: (background != null ? jsonDecode(background!) : null)
          as Map<String, dynamic>?,
      status: (status != null ? jsonDecode(status!) : null)
          as Map<String, dynamic>?,
      sharedWith: sharedWith
          .map(
            (shared) => SharedWith.fromJson(jsonDecode(shared) as Map<String, dynamic>),
          )
          .toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      settings: (settings != null ? jsonDecode(settings!) : null)
          as Map<String, dynamic>?,
    );
  }

  CollectionModelIsar copyWithCollectionModel(CollectionModel model) {
    return CollectionModelIsar(
      id: id,
      firestoreId: model.id,
      userId: model.userId,
      parentCollection: model.parentCollection,
      name: model.name,
      description: model.description ?? description,
      category: model.category,
      subcollectionCount: model.subcollectionCount,
      urlCount: model.urlCount,
      icon: model.icon != null ? jsonEncode(model.icon) : icon,
      background:
          model.background != null ? jsonEncode(model.background) : background,
      status: model.status != null ? jsonEncode(model.status) : status,
      sharedWith: model.sharedWith.map(jsonEncode).toList(),
      createdAt: model.createdAt,
      updatedAt: DateTime.now(),
      settings: model.settings != null ? jsonEncode(model.settings) : settings,
    );
  }
}
