import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_category_entity.dart';

part 'collection_category_model.g.dart';

@Collection()
class CollectionCategoryModel {
  CollectionCategoryModel({
    this.isarId = Isar.autoIncrement,
    required this.collectionId,
    required this.categoryId,
    required this.createdAt,
  });

  final Id isarId;

  @Index()
  final String collectionId;

  @Index()
  final String categoryId;

  @Index()
  final DateTime createdAt;

  // Convert from Entity
  factory CollectionCategoryModel.fromEntity(CollectionCategoryEntity e) {
    return CollectionCategoryModel(
      collectionId: e.collectionId,
      categoryId: e.categoryId,
      createdAt: e.createdAt,
    );
  }

  // Convert to Entity
  CollectionCategoryEntity toEntity() {
    return CollectionCategoryEntity(
      collectionId: collectionId,
      categoryId: categoryId,
      createdAt: createdAt,
    );
  }

  // CopyWith method
  CollectionCategoryModel copyWith({
    Id? isarId,
    String? collectionId,
    String? categoryId,
    DateTime? createdAt,
  }) {
    return CollectionCategoryModel(
      isarId: isarId ?? this.isarId,
      collectionId: collectionId ?? this.collectionId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON (snake_case for remote DB)
  Map<String, dynamic> toJson() {
    return {
      'collection_id': collectionId,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert from JSON (snake_case)
  factory CollectionCategoryModel.fromJson(Map<String, dynamic> json) {
    return CollectionCategoryModel(
      collectionId: json['collection_id'] as String,
      categoryId: json['category_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
