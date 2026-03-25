import '../../domain/entities/item.dart' as domain;
import '../models/item_model.dart' as data;

class ItemMapper {
  static domain.Item toEntity(data.ItemModel model) {
    return domain.Item(
      id: model.uid,
      ownerId: model.ownerId,
      title: model.title,
      description: model.description,
      imagePath: model.imagePath,
      imageUrl: model.imageUrl,
      link: model.link,
      annotation: model.annotation,
      tags: model.tags,
      status: model.status,
      position: model.position,
      isPinned: model.isPinned,
      clickCount: model.clickCount,
      lastAccessedAt: model.lastAccessedAt,
      isDeleted: model.isDeleted,
      deletedAt: model.deletedAt,
      faviconUrl: model.faviconUrl,
      dominantColor: model.dominantColor,
      siteName: model.siteName,
      canonicalUrl: model.canonicalUrl,
      contentType: model.contentType,
      publishedAt: model.publishedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      collectionId: model.collectionUid,
    );
  }

  static data.ItemModel toModel(domain.Item entity) {
    return data.ItemModel()
      ..uid = entity.id
      ..ownerId = entity.ownerId
      ..title = entity.title
      ..description = entity.description
      ..imagePath = entity.imagePath
      ..imageUrl = entity.imageUrl
      ..link = entity.link
      ..annotation = entity.annotation
      ..tags = entity.tags
      ..status = entity.status
      ..position = entity.position
      ..collectionUid = entity.collectionId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isPinned = entity.isPinned
      ..clickCount = entity.clickCount
      ..lastAccessedAt = entity.lastAccessedAt
      ..isDeleted = entity.isDeleted
      ..deletedAt = entity.deletedAt
      ..faviconUrl = entity.faviconUrl
      ..dominantColor = entity.dominantColor
      ..siteName = entity.siteName
      ..canonicalUrl = entity.canonicalUrl
      ..contentType = entity.contentType
      ..publishedAt = entity.publishedAt;
  }
}
