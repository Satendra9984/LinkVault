import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_tag_entity.dart';

part 'collection_tag_model.g.dart';

@Collection()
class CollectionTagModel {
  CollectionTagModel({
    this.isarId = Isar.autoIncrement,
    required this.collectionId,
    required this.tagId,
    required this.createdAt,
  });

  final Id isarId;

  @Index()
  final String collectionId;

  @Index()
  final String tagId;

  @Index()
  final DateTime createdAt;

  // Convert from entity to model
  factory CollectionTagModel.fromEntity(CollectionTagEntity e) {
    return CollectionTagModel(
      collectionId: e.collectionId,
      tagId: e.tagId,
      createdAt: e.createdAt,
    );
  }

  // Convert from model to entity
  CollectionTagEntity toEntity() {
    return CollectionTagEntity(
      collectionId: collectionId,
      tagId: tagId,
      createdAt: createdAt,
    );
  }

  // CopyWith method
  CollectionTagModel copyWith({
    Id? isarId,
    String? collectionId,
    String? tagId,
    DateTime? createdAt,
  }) {
    return CollectionTagModel(
      isarId: isarId ?? this.isarId,
      collectionId: collectionId ?? this.collectionId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // To JSON (snake_case keys for remote DB)
  Map<String, dynamic> toJson() {
    return {
      'collection_id': collectionId,
      'tag_id': tagId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // From JSON (snake_case keys)
  factory CollectionTagModel.fromJson(Map<String, dynamic> json) {
    return CollectionTagModel(
      collectionId: json['collection_id'] as String,
      tagId: json['tag_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
