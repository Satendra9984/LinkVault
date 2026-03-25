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
      description: model.description,
      category: model.category,
      colorHex: model.colorHex,
      iconName: model.iconName,
      iconJson: model.iconJson,
      position: model.position,
      isPinned: model.isPinned,
      isArchived: model.isArchived,
      isDeleted: model.isDeleted,
      childCount: model.childCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastAccessedAt: model.lastAccessedAt,
      itemsLayout: model.itemsLayout,
      childCollectionsLayout: model.childCollectionsLayout,
      itemsSortDefault: model.itemsSortDefault,
      openLinksIn: model.openLinksIn,
      showLinkPreviews: model.showLinkPreviews,
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
      ..description = entity.description
      ..category = entity.category
      ..colorHex = entity.colorHex
      ..iconName = entity.iconName
      ..iconJson = entity.iconJson
      ..position = entity.position
      ..isPinned = entity.isPinned
      ..isArchived = entity.isArchived
      ..isDeleted = entity.isDeleted
      ..childCount = entity.childCount
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..lastAccessedAt = entity.lastAccessedAt
      ..itemsLayout = entity.itemsLayout
      ..childCollectionsLayout = entity.childCollectionsLayout
      ..itemsSortDefault = entity.itemsSortDefault
      ..openLinksIn = entity.openLinksIn
      ..showLinkPreviews = entity.showLinkPreviews
      ..itemCount = entity.itemCount;
  }
}
