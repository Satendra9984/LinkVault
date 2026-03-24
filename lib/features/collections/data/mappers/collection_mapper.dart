import '../../domain/entities/collection.dart';
import '../models/collection_model.dart';

class CollectionMapper {
  static Collection toEntity(CollectionModel model) {
    return Collection(
      id: model.uid,
      ownerId: model.ownerId,
      parentId: model.parentId,
      isShared: model.isShared,
      title: model.title,
      category: model.category,
      colorHex: model.colorHex,
      iconName: model.iconName,
      position: model.position,
      isPinned: model.isPinned,
      isArchived: model.isArchived,
      isDeleted: model.isDeleted,
      childCount: model.childCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      itemCount: model.itemCount,
    );
  }

  static CollectionModel toModel(Collection entity) {
    return CollectionModel()
      ..uid = entity.id
      ..ownerId = entity.ownerId
      ..parentId = entity.parentId
      ..isShared = entity.isShared
      ..title = entity.title
      ..category = entity.category
      ..colorHex = entity.colorHex
      ..iconName = entity.iconName
      ..position = entity.position
      ..isPinned = entity.isPinned
      ..isArchived = entity.isArchived
      ..isDeleted = entity.isDeleted
      ..childCount = entity.childCount
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..itemCount = entity.itemCount;
  }
}
