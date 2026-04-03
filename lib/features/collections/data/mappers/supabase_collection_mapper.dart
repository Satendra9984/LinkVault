import 'dart:convert';

import '../../domain/collection_display_defaults.dart';
import '../../domain/entities/collection.dart';

class SupabaseCollectionMapper {
  /// JSON for Supabase. Empty-string UUID fields become absent or null so Postgres
  /// does not see `""` (invalid input syntax for type uuid).
  static Map<String, dynamic> toJson(Collection entity, String ownerId) {
    final parent = entity.parentId;
    final parentForDb =
        (parent != null && parent.trim().isNotEmpty) ? parent : null;

    final map = <String, dynamic>{
      'owner_id': ownerId,
      'parent_id': parentForDb,
      'title': entity.title,
      'description': _emptyToNull(entity.description),
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
      'last_accessed_at': entity.lastAccessedAt?.toIso8601String(),
      'items_layout': CollectionLayoutMode.normalize(entity.itemsLayout),
      'child_collections_layout':
          CollectionLayoutMode.normalize(entity.childCollectionsLayout),
      'items_sort_default':
          CollectionItemsSortDefault.normalize(entity.itemsSortDefault),
      'open_links_in': CollectionOpenLinksIn.normalize(entity.openLinksIn),
      'show_link_previews': entity.showLinkPreviews,
    };

    final iconJson = _decodeIconJson(entity.iconJson);
    if (iconJson != null) {
      map['icon_json'] = iconJson;
    } else {
      map['icon_json'] = null;
    }

    if (entity.id.trim().isNotEmpty) {
      map['id'] = entity.id;
    }

    return map;
  }

  /// Full `lv_collections` row for backup [v2.0] JSON (nullable `owner_id`, includes `is_shared`).
  ///
  /// `deleted_at` is included for table parity; the domain model does not carry it yet (always null).
  static Map<String, dynamic> toLvCollectionsBackupRow(Collection entity) {
    final parent = entity.parentId;
    final parentForDb =
        (parent != null && parent.trim().isNotEmpty) ? parent : null;

    final map = <String, dynamic>{
      'id': entity.id,
      'owner_id': entity.ownerId,
      'parent_id': parentForDb,
      'title': entity.title,
      'description': _emptyToNull(entity.description),
      'category': entity.category,
      'color_hex': entity.colorHex,
      'icon_name': entity.iconName,
      'position': entity.position,
      'is_pinned': entity.isPinned,
      'is_archived': entity.isArchived,
      'is_deleted': entity.isDeleted,
      'deleted_at': null,
      'url_count': entity.itemCount,
      'child_count': entity.childCount,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
      'last_accessed_at': entity.lastAccessedAt?.toIso8601String(),
      'items_layout': CollectionLayoutMode.normalize(entity.itemsLayout),
      'child_collections_layout':
          CollectionLayoutMode.normalize(entity.childCollectionsLayout),
      'items_sort_default':
          CollectionItemsSortDefault.normalize(entity.itemsSortDefault),
      'open_links_in': CollectionOpenLinksIn.normalize(entity.openLinksIn),
      'show_link_previews': entity.showLinkPreviews,
      'is_shared': entity.isShared,
    };

    final iconJson = _decodeIconJson(entity.iconJson);
    map['icon_json'] = iconJson;

    return map;
  }

  static String? _emptyToNull(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  static Map<String, dynamic>? _decodeIconJson(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    try {
      final decoded = jsonDecode(t);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _iconJsonToEntityField(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? null : t;
    }
    try {
      return jsonEncode(raw);
    } catch (_) {
      return null;
    }
  }

  static Collection fromRow(Map<String, dynamic> map) {
    final desc = map['description'];
    return Collection(
      id: map['id']?.toString() ?? '',
      ownerId: map['owner_id']?.toString(),
      parentId: map['parent_id']?.toString(),
      isShared: map['is_shared'] ?? false,
      title: map['title'] ?? map['name'] ?? 'Untitled',
      description: desc is String ? desc : desc?.toString(),
      category: map['category'] ?? 'general',
      colorHex: map['color_hex'] ?? map['color'] ?? '#6366F1',
      iconName: map['icon_name'] ?? map['icon'] ?? 'folder',
      iconJson: _iconJsonToEntityField(map['icon_json']),
      position: (map['position'] as num?)?.toDouble() ?? 0.0,
      isPinned: map['is_pinned'] ?? false,
      isArchived: map['is_archived'] ?? false,
      isDeleted: map['is_deleted'] ?? false,
      childCount: map['child_count'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      lastAccessedAt: map['last_accessed_at'] != null
          ? DateTime.tryParse(map['last_accessed_at'].toString())
          : null,
      itemsLayout: CollectionLayoutMode.normalize(map['items_layout']?.toString()),
      childCollectionsLayout: CollectionLayoutMode.normalize(
          map['child_collections_layout']?.toString()),
      itemsSortDefault:
          CollectionItemsSortDefault.normalize(map['items_sort_default']?.toString()),
      openLinksIn: CollectionOpenLinksIn.normalize(map['open_links_in']?.toString()),
      showLinkPreviews: map['show_link_previews'] ?? true,
      itemCount: map['url_count'] ?? map['item_count'] ?? 0,
    );
  }
}
