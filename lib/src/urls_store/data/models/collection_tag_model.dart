
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_entity.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_tag_entity.dart';



@Collection()
class CollectionTagModel extends Equatable {
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

  @override
  List<Object?> get props => [isarId, collectionId, tagId, createdAt];

  factory CollectionTagModel.fromEntity(CollectionTagEntity e) {
    return CollectionTagModel(
      collectionId: e.collectionId,
      tagId: e.tagId,
      createdAt: e.createdAt,
    );
  }

  CollectionTagEntity toEntity() {
    return CollectionTagEntity(
      collectionId: collectionId,
      tagId: tagId,
      createdAt: createdAt,
    );
  }
}
