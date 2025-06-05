import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/url_entity.dart';

part 'url_model.g.dart';

@Collection()
class UrlModel {
  UrlModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.collectionId,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.faviconUrl,
    this.dominantColor,
    required this.position,
    required this.isPinned,
    required this.isArchived,
    required this.clickCount,
    required this.metadataJson,
    required this.settingsJson,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
  });

  final Id isarId;

  @Index()
  final String id;

  @Index()
  final String collectionId;

  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final String? dominantColor;

  @Index()
  final int position;

  @Index()
  final bool isPinned;

  @Index()
  final bool isArchived;

  final int clickCount;
  final String metadataJson;
  final String settingsJson;

  @Index()
  final DateTime createdAt;

  @Index()
  final DateTime updatedAt;

  final DateTime? lastAccessedAt;

  // Convert from entity
  factory UrlModel.fromEntity(UrlEntity e) {
    return UrlModel(
      id: e.id,
      collectionId: e.collectionId,
      url: e.url,
      title: e.title,
      description: e.description,
      thumbnailUrl: e.thumbnailUrl,
      faviconUrl: e.faviconUrl,
      dominantColor: e.dominantColor,
      position: e.position,
      isPinned: e.isPinned,
      isArchived: e.isArchived,
      clickCount: e.clickCount,
      metadataJson: jsonEncode(e.metadata),
      settingsJson: jsonEncode(e.settings),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      lastAccessedAt: e.lastAccessedAt,
    );
  }

  // Convert to entity
  UrlEntity toEntity() {
    return UrlEntity(
      id: id,
      collectionId: collectionId,
      url: url,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      faviconUrl: faviconUrl,
      dominantColor: dominantColor,
      position: position,
      isPinned: isPinned,
      isArchived: isArchived,
      clickCount: clickCount,
      metadata: jsonDecode(metadataJson),
      settings: jsonDecode(settingsJson),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastAccessedAt: lastAccessedAt,
    );
  }

  // CopyWith method
  UrlModel copyWith({
    Id? isarId,
    String? id,
    String? collectionId,
    String? url,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? faviconUrl,
    String? dominantColor,
    int? position,
    bool? isPinned,
    bool? isArchived,
    int? clickCount,
    String? metadataJson,
    String? settingsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
  }) {
    return UrlModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      dominantColor: dominantColor ?? this.dominantColor,
      position: position ?? this.position,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      clickCount: clickCount ?? this.clickCount,
      metadataJson: metadataJson ?? this.metadataJson,
      settingsJson: settingsJson ?? this.settingsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  // Convert to JSON for remote API (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_id': collectionId,
      'url': url,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'favicon_url': faviconUrl,
      'dominant_color': dominantColor,
      'position': position,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'click_count': clickCount,
      'metadata': jsonDecode(metadataJson),
      'settings': jsonDecode(settingsJson),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory UrlModel.fromJson(Map<String, dynamic> json) {
    return UrlModel(
      id: json['id'] as String,
      collectionId: json['collection_id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      faviconUrl: json['favicon_url'] as String?,
      dominantColor: json['dominant_color'] as String?,
      position: json['position'] as int,
      isPinned: json['is_pinned'] as bool,
      isArchived: json['is_archived'] as bool,
      clickCount: json['click_count'] as int,
      metadataJson: jsonEncode(json['metadata']),
      settingsJson: jsonEncode(json['settings']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
    );
  }
}
