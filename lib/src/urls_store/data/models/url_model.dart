import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/url_entity.dart';

part 'url_model.g.dart';


@Collection()
class UrlModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String remoteId; // UUID from Supabase
  
  @Index()
  late String collectionId;
  
  @Index()
  late String userId;
  
  late String url;
  String? title;
  String? description;
  String? thumbnailUrl;
  String? faviconUrl;
  
  int position = 0;
  
  @Index()
  bool isPinned = false; // Favourite feature
  
  int clickCount = 0;
  
  @Index()
  DateTime? lastClickedAt; // For recent URLs feature
  
  late String metadataJson;
  late String settingsJson;
  
  @Index()
  late DateTime createdAt;
  late DateTime updatedAt;
  
  @Index()
  late DateTime lastSyncedAt;
  bool needsSync = false;
  
  // Convert to Domain Entity
  UrlEntity toEntity() {
    return UrlEntity(
      id: remoteId,
      collectionId: collectionId,
      userId: userId,
      url: url,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      faviconUrl: faviconUrl,
      position: position,
      isPinned: isPinned,
      clickCount: clickCount,
      lastClickedAt: lastClickedAt,
      metadata: jsonDecode(metadataJson),
      settings: jsonDecode(settingsJson),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  // Create from Domain Entity
  static UrlModel fromEntity(UrlEntity entity) {
    return UrlModel()
      ..remoteId = entity.id
      ..collectionId = entity.collectionId
      ..userId = entity.userId
      ..url = entity.url
      ..title = entity.title
      ..description = entity.description
      ..thumbnailUrl = entity.thumbnailUrl
      ..faviconUrl = entity.faviconUrl
      ..position = entity.position
      ..isPinned = entity.isPinned
      ..clickCount = entity.clickCount
      ..lastClickedAt = entity.lastClickedAt
      ..metadataJson = jsonEncode(entity.metadata)
      ..settingsJson = jsonEncode(entity.settings)
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..lastSyncedAt = DateTime.now()
      ..needsSync = false;
  }
  
  // Create from Supabase JSON
  static UrlModel fromSupabaseJson(Map<String, dynamic> json) {
    return UrlModel()
      ..remoteId = json['id']
      ..collectionId = json['collection_id']
      ..userId = json['user_id']
      ..url = json['url']
      ..title = json['title']
      ..description = json['description']
      ..thumbnailUrl = json['thumbnail_url']
      ..faviconUrl = json['favicon_url']
      ..position = json['position'] ?? 0
      ..isPinned = json['is_pinned'] ?? false
      ..clickCount = json['click_count'] ?? 0
      ..lastClickedAt = json['last_clicked_at'] != null ? DateTime.parse(json['last_clicked_at']) : null
      ..metadataJson = jsonEncode(json['metadata'] ?? {})
      ..settingsJson = jsonEncode(json['settings'] ?? {})
      ..createdAt = DateTime.parse(json['created_at'])
      ..updatedAt = DateTime.parse(json['updated_at'])
      ..lastSyncedAt = DateTime.now()
      ..needsSync = false;
  }
  
  // Convert to Supabase JSON
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': remoteId.isEmpty ? null : remoteId,
      'collection_id': collectionId,
      'user_id': userId,
      'url': url,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'favicon_url': faviconUrl,
      'position': position,
      'is_pinned': isPinned,
      'click_count': clickCount,
      'last_clicked_at': lastClickedAt?.toIso8601String(),
      'metadata': jsonDecode(metadataJson),
      'settings': jsonDecode(settingsJson),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

