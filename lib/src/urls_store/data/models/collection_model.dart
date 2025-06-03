import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/data/models/url_model.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_background.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_icon.dart';
import '../../domain/entities/collection_entity.dart';

part 'collection_model.g.dart';

@Collection()
class CollectionModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String remoteId; // UUID from Supabase
  
  @Index()
  late String userId;
  
  String? parentCollectionId;
  late String name;
  String? description;
  
  // Serialized as JSON strings in Isar
  late String iconJson;
  late String backgroundJson;
  
  @Index()
  bool isPinned = false;
  bool isArchived = false;
  int position = 0;
  
  String layoutType = 'grid';
  String sortOrder = 'manual';
  String visibility = 'private';
  
  late String statusJson; // Map<String, dynamic> as JSON
  late String settingsJson; // Map<String, dynamic> as JSON
  
  @Index()
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? lastAccessedAt;
  
  @Index()
  late DateTime lastSyncedAt; // For offline-first sync
  bool needsSync = false; // Mark for upload to Supabase
  
  // Relationships (Isar will handle these)
  final urls = IsarLinks<UrlModel>();
  
  // Convert to Domain Entity
  CollectionEntity toEntity() {
    return CollectionEntity(
      id: remoteId,
      userId: userId,
      parentCollectionId: parentCollectionId,
      name: name,
      description: description,
      icon: CollectionIcon.fromJson(jsonDecode(iconJson)),
      background: CollectionBackground.fromJson(jsonDecode(backgroundJson)),
      isPinned: isPinned,
      isArchived: isArchived,
      position: position,
      layoutType: layoutType,
      sortOrder: sortOrder,
      visibility: visibility,
      status: jsonDecode(statusJson),
      settings: jsonDecode(settingsJson),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastAccessedAt: lastAccessedAt,
      urls: urls.map((url) => url.toEntity()).toList(),
    );
  }
  
  // Create from Domain Entity
  static CollectionModel fromEntity(CollectionEntity entity) {
    return CollectionModel()
      ..remoteId = entity.id
      ..userId = entity.userId
      ..parentCollectionId = entity.parentCollectionId
      ..name = entity.name
      ..description = entity.description
      ..iconJson = jsonEncode(entity.icon.toJson())
      ..backgroundJson = jsonEncode(entity.background.toJson())
      ..isPinned = entity.isPinned
      ..isArchived = entity.isArchived
      ..position = entity.position
      ..layoutType = entity.layoutType
      ..sortOrder = entity.sortOrder
      ..visibility = entity.visibility
      ..statusJson = jsonEncode(entity.status)
      ..settingsJson = jsonEncode(entity.settings)
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..lastAccessedAt = entity.lastAccessedAt
      ..lastSyncedAt = DateTime.now()
      ..needsSync = false;
  }
  
  // Create from Supabase JSON
  static CollectionModel fromSupabaseJson(Map<String, dynamic> json) {
    return CollectionModel()
      ..remoteId = json['id']
      ..userId = json['user_id']
      ..parentCollectionId = json['parent_collection_id']
      ..name = json['name']
      ..description = json['description']
      ..iconJson = jsonEncode(json['icon'] ?? {'type': 'emoji', 'value': '📁', 'color': '#6B7280'})
      ..backgroundJson = jsonEncode(json['background'] ?? {'color': '#F9FAFB', 'pattern': 'none', 'opacity': 1.0})
      ..isPinned = json['is_pinned'] ?? false
      ..isArchived = json['is_archived'] ?? false
      ..position = json['position'] ?? 0
      ..layoutType = json['layout_type'] ?? 'grid'
      ..sortOrder = json['sort_order'] ?? 'manual'
      ..visibility = json['visibility'] ?? 'private'
      ..statusJson = jsonEncode(json['status'] ?? {})
      ..settingsJson = jsonEncode(json['settings'] ?? {})
      ..createdAt = DateTime.parse(json['created_at'])
      ..updatedAt = DateTime.parse(json['updated_at'])
      ..lastAccessedAt = json['last_accessed_at'] != null ? DateTime.parse(json['last_accessed_at']) : null
      ..lastSyncedAt = DateTime.now()
      ..needsSync = false;
  }
  
  // Convert to Supabase JSON for API calls
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': remoteId.isEmpty ? null : remoteId, // null for new collections
      'user_id': userId,
      'parent_collection_id': parentCollectionId,
      'name': name,
      'description': description,
      'icon': jsonDecode(iconJson),
      'background': jsonDecode(backgroundJson),
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'position': position,
      'layout_type': layoutType,
      'sort_order': sortOrder,
      'visibility': visibility,
      'status': jsonDecode(statusJson),
      'settings': jsonDecode(settingsJson),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}