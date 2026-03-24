import '../../domain/entities/collection.dart';

class SupabaseCollectionMapper {
  static Map<String, dynamic> toJson(Collection entity, String ownerId) {
    return {
      'id': entity.id,
      'owner_id': ownerId,
      'parent_id': entity.parentId,
      'title': entity.title,
      'category': entity.category,
      'color_hex': entity.colorHex,
      'icon_name': entity.iconName,
      'position': entity.position,
      'is_pinned': entity.isPinned,
      'is_archived': entity.isArchived,
      'is_deleted': entity.isDeleted,
      'url_count': entity.itemCount,
      'child_count': entity.childCount,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }
}
