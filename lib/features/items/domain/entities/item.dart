import 'package:equatable/equatable.dart';

// Domain status aligned with `public.lv_urls.status`.
enum ItemStatus { unread, read, archived }

/// Unified LV URL item contract (URLItem).
///
/// This is the single source-of-truth domain model for URL items across:
/// - Supabase `public.lv_urls`
/// - ObjectBox offline store
/// - Form and UI flows
///
/// Curate-era "custom fields" are intentionally removed to avoid confusion.
class Item extends Equatable {
  final String id;
  final String? ownerId;
  final String collectionId;

  // Core URL data
  final String? link;
  final String title;
  final String? description;

  /// Preview image / thumbnail URL (maps to `lv_urls.thumbnail_url`).
  final String? imageUrl;

  /// Local-only thumbnail path for offline image picking.
  final String? imagePath;

  /// Favicon URL (maps to `lv_urls.favicon_url`).
  final String? faviconUrl;

  final String? dominantColor;
  final String? tags;

  /// Notes stored in `lv_urls.annotation`.
  final String? annotation;

  // Future fields (recommended)
  final String? siteName;
  final String? canonicalUrl;
  final String? contentType;
  final DateTime? publishedAt;

  // URL lifecycle / ordering / analytics
  final ItemStatus status;
  final bool isPinned;
  final double position;
  final int clickCount;
  final DateTime? lastAccessedAt;

  /// If set, overrides the parent collection open-links setting; null = inherit.
  /// Use `in_app` or `external_browser` (same as collection `open_links_in`).
  final String? openLinksInOverride;

  // Soft delete
  final bool isDeleted;
  final DateTime? deletedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Item({
    required this.id,
    this.ownerId,
    required this.collectionId,
    this.link,
    required this.title,
    this.description,
    this.imageUrl,
    this.imagePath,
    this.faviconUrl,
    this.dominantColor,
    this.tags,
    this.annotation,
    required this.status,
    this.isPinned = false,
    this.position = 0.0,
    this.clickCount = 0,
    this.lastAccessedAt,
    this.openLinksInOverride,
    this.isDeleted = false,
    this.deletedAt,
    this.siteName,
    this.canonicalUrl,
    this.contentType,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Item copyWith({
    String? id,
    String? ownerId,
    String? collectionId,
    String? link,
    String? title,
    String? description,
    String? imageUrl,
    String? imagePath,
    String? faviconUrl,
    String? dominantColor,
    String? tags,
    String? annotation,
    ItemStatus? status,
    bool? isPinned,
    double? position,
    int? clickCount,
    DateTime? lastAccessedAt,
    String? openLinksInOverride,
    bool? clearOpenLinksInOverride,
    bool? isDeleted,
    DateTime? deletedAt,
    String? siteName,
    String? canonicalUrl,
    String? contentType,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      collectionId: collectionId ?? this.collectionId,
      link: link ?? this.link,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      dominantColor: dominantColor ?? this.dominantColor,
      tags: tags ?? this.tags,
      annotation: annotation ?? this.annotation,
      status: status ?? this.status,
      isPinned: isPinned ?? this.isPinned,
      position: position ?? this.position,
      clickCount: clickCount ?? this.clickCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      openLinksInOverride: clearOpenLinksInOverride == true
          ? null
          : (openLinksInOverride ?? this.openLinksInOverride),
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      siteName: siteName ?? this.siteName,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      contentType: contentType ?? this.contentType,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        collectionId,
        link,
        title,
        description,
        imageUrl,
        imagePath,
        faviconUrl,
        dominantColor,
        tags,
        annotation,
        siteName,
        canonicalUrl,
        contentType,
        publishedAt,
        status,
        isPinned,
        position,
        clickCount,
        lastAccessedAt,
        openLinksInOverride,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
      ];
}
