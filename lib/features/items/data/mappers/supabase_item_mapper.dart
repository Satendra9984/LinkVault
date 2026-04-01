import '../../domain/entities/item.dart';

class SupabaseItemMapper {
  static String? _normalizeUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  /// Matches the favicon URL strategy used in `UrlFaviconTile`.
  static String? _faviconUrlFromLink(String? rawUrl) {
    final normalized = _normalizeUrl(rawUrl);
    if (normalized == null) return null;
    return 'https://www.google.com/s2/favicons?sz=64&domain_url=$normalized';
  }

  /// Parse a `lv_urls` row from PostgREST into a domain [Item].
  static Item fromRow(Map<String, dynamic> map) {
    final lvStatus = map['status'] as String?;
    final mappedStatus = switch (lvStatus) {
      'unread' => ItemStatus.unread,
      'read' => ItemStatus.read,
      'archived' => ItemStatus.archived,
      _ => ItemStatus.unread,
    };

    final webDescription = map['description'] as String?;
    final annotationNotes = map['annotation'] as String?;
    final mappedDescription = webDescription ?? annotationNotes;

    final publishedAt = map['published_at'] as String?;
    final lastAccessedAt = map['last_accessed_at'] as String?;
    final deletedAt = map['deleted_at'] as String?;

    return Item(
      id: map['id']?.toString() ?? '',
      ownerId: map['owner_id']?.toString(),
      title: map['title'] as String? ?? '',
      description: mappedDescription,
      imagePath: null,
      imageUrl: map['thumbnail_url'] as String?,
      link: map['url'] as String?,
      annotation: annotationNotes,
      tags: map['tags'] as String?,
      status: mappedStatus,
      position: (map['position'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      collectionId: map['collection_id']?.toString() ?? '',
      faviconUrl: map['favicon_url'] as String?,
      dominantColor: map['dominant_color'] as String?,
      isPinned: map['is_pinned'] as bool? ?? false,
      clickCount: map['click_count'] as int? ?? 0,
      lastAccessedAt:
          lastAccessedAt == null ? null : DateTime.parse(lastAccessedAt),
      isDeleted: map['is_deleted'] as bool? ?? false,
      deletedAt: deletedAt == null ? null : DateTime.parse(deletedAt),
      siteName: map['site_name'] as String?,
      canonicalUrl: map['canonical_url'] as String?,
      contentType: map['content_type'] as String?,
      publishedAt: publishedAt == null ? null : DateTime.parse(publishedAt),
      openLinksInOverride: map['open_links_in_override'] as String?,
    );
  }

  static String _toLvStatus(ItemStatus status) {
    // Temporary mapping until domain entity is fully aligned in a later todo.
    return switch (status) {
      ItemStatus.unread => 'unread',
      ItemStatus.read => 'read',
      ItemStatus.archived => 'archived',
    };
  }

  /// JSON payload for `public.lv_urls` INSERT.
  static Map<String, dynamic> toInsertJson(
    Item entity, {
    required String ownerId,
    String? uploadedImageUrl,
  }) {
    final favicon = entity.faviconUrl ?? _faviconUrlFromLink(entity.link);
    return {
      'id': entity.id,
      'owner_id': ownerId,
      'collection_id': entity.collectionId,

      // Core URL data
      'url': entity.link,
      'title': entity.title,
      // lv_urls.description: extracted webpage summary
      'description': entity.description,
      // lv_urls.annotation: user notes
      'annotation': entity.annotation,

      // Preview / visuals
      'thumbnail_url': uploadedImageUrl ?? entity.imageUrl,
      'favicon_url': favicon,
      'dominant_color': entity.dominantColor,

      // User metadata
      'tags': entity.tags,

      // State / ordering
      'status': _toLvStatus(entity.status),
      'is_pinned': entity.isPinned,
      'position': entity.position,
      'click_count': entity.clickCount,
      'last_accessed_at': entity.lastAccessedAt?.toIso8601String(),

      // Soft delete
      'is_deleted': entity.isDeleted,
      'deleted_at': entity.deletedAt?.toIso8601String(),

      // Timestamps
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),

      // Future URL metadata
      'site_name': entity.siteName,
      'canonical_url': entity.canonicalUrl,
      'content_type': entity.contentType,
      'published_at': entity.publishedAt?.toIso8601String(),
      'open_links_in_override': entity.openLinksInOverride,
    };
  }

  /// JSON payload for `public.lv_urls` UPDATE.
  ///
  /// IMPORTANT: Counters (`click_count`) and analytics (`last_accessed_at`)
  /// are omitted so specialized repository methods can update them atomically.
  /// `is_pinned` and `open_links_in_override` are included for form saves.
  static Map<String, dynamic> toUpdateJson(
    Item entity, {
    String? uploadedImageUrl,
  }) {
    final favicon = entity.faviconUrl ?? _faviconUrlFromLink(entity.link);
    return {
      'url': entity.link,
      'collection_id': entity.collectionId,
      'title': entity.title,

      // lv_urls.description: extracted webpage summary
      'description': entity.description,
      // lv_urls.annotation: user notes
      'annotation': entity.annotation,
      'tags': entity.tags,

      // Preview visuals (thumbnail only for now).
      'thumbnail_url': uploadedImageUrl ?? entity.imageUrl,
      'favicon_url': favicon,
      'dominant_color': entity.dominantColor,

      // Future URL metadata
      'site_name': entity.siteName,
      'canonical_url': entity.canonicalUrl,
      'content_type': entity.contentType,
      'published_at': entity.publishedAt?.toIso8601String(),

      // Keep state in sync with the current status toggle UI.
      'status': _toLvStatus(entity.status),

      // Ordering
      'position': entity.position,

      // Timestamps
      'updated_at': entity.updatedAt.toIso8601String(),

      // Per-URL open behavior (nullable = inherit collection)
      'open_links_in_override': entity.openLinksInOverride,

      // Form/edit screen may update pin alongside other fields
      'is_pinned': entity.isPinned,
    };
  }
}
