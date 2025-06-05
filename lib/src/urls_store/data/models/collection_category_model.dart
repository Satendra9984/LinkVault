

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_category_entity.dart';

@Collection()
class CollectionCategoryModel extends Equatable {
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

  @override
  List<Object?> get props => [isarId, collectionId, categoryId, createdAt];

  factory CollectionCategoryModel.fromEntity(CollectionCategoryEntity e) {
    return CollectionCategoryModel(
      collectionId: e.collectionId,
      categoryId: e.categoryId,
      createdAt: e.createdAt,
    );
  }

  CollectionCategoryEntity toEntity() {
    return CollectionCategoryEntity(
      collectionId: collectionId,
      categoryId: categoryId,
      createdAt: createdAt,
    );
  }
}