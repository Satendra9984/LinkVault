import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_background.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_entity.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_icon.dart';

part 'collection_model.g.dart';

@Collection()
class CollectionModel {
  CollectionModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.userId,
    this.parentCollectionId,
    required this.name,
    this.description,
    required this.iconJson,
    required this.backgroundJson,
    required this.isPinned,
    required this.isArchived,
    required this.position,
    required this.layoutType,
    required this.sortOrder,
    required this.visibility,
    required this.urlCount,
    required this.totalClicks,
    required this.statusJson,
    required this.settingsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.lastAccessedAt,
  });

  final Id isarId;

  @Index()
  final String id; // will be used for remote database(supabase now) row id

  @Index()
  final String userId;

  final String? parentCollectionId;  // collections are nested,null for root collection
  final String name; // collection name
  final String? description;  // if user wants to
  final String iconJson;      // collection icon
  final String backgroundJson;  // some background details for ui

  @Index()
  final bool isPinned;  // works as favourites

  @Index()
  final bool isArchived;

  @Index()
  final int position;  // if user reordered it

  final String layoutType;  // grid, list etc. for child collections ui
  final String sortOrder;   // child collection sorting order
  final String visibility;  // may be they will be shared in future feature

  final int urlCount;      // collection store urls so their count
  final int totalClicks;   // for filtering purpose, most frequent sorting

  final String statusJson; 
  final String settingsJson;  // other general settings mainly will use for urls

  @Index()
  final DateTime createdAt;

  @Index()
  final DateTime updatedAt;

  @Index()
  final DateTime? lastAccessedAt; // for recent collection searching, filtering

  // Convert from Entity to Model
  factory CollectionModel.fromEntity(CollectionEntity e) {
    return CollectionModel(
      id: e.id,
      userId: e.userId,
      parentCollectionId: e.parentCollectionId,
      name: e.name,
      description: e.description,
      iconJson: jsonEncode(e.icon.toJson()),
      backgroundJson: jsonEncode(e.background.toJson()),
      isPinned: e.isPinned,
      isArchived: e.isArchived,
      position: e.position,
      layoutType: e.layoutType,
      sortOrder: e.sortOrder,
      visibility: e.visibility,
      urlCount: e.urlCount,
      totalClicks: e.totalClicks,
      statusJson: jsonEncode(e.status),
      settingsJson: jsonEncode(e.settings),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      lastAccessedAt: e.lastAccessedAt,
    );
  }

  // Convert from Model to Entity
  CollectionEntity toEntity() {
    return CollectionEntity(
      id: id,
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
      urlCount: urlCount,
      totalClicks: totalClicks,
      status: jsonDecode(statusJson),
      settings: jsonDecode(settingsJson),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastAccessedAt: lastAccessedAt,
    );
  }

  // CopyWith
  CollectionModel copyWith({
    Id? isarId,
    String? id,
    String? userId,
    String? parentCollectionId,
    String? name,
    String? description,
    String? iconJson,
    String? backgroundJson,
    bool? isPinned,
    bool? isArchived,
    int? position,
    String? layoutType,
    String? sortOrder,
    String? visibility,
    int? urlCount,
    int? totalClicks,
    String? statusJson,
    String? settingsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
  }) {
    return CollectionModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentCollectionId: parentCollectionId ?? this.parentCollectionId,
      name: name ?? this.name,
      description: description ?? this.description,
      iconJson: iconJson ?? this.iconJson,
      backgroundJson: backgroundJson ?? this.backgroundJson,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      position: position ?? this.position,
      layoutType: layoutType ?? this.layoutType,
      sortOrder: sortOrder ?? this.sortOrder,
      visibility: visibility ?? this.visibility,
      urlCount: urlCount ?? this.urlCount,
      totalClicks: totalClicks ?? this.totalClicks,
      statusJson: statusJson ?? this.statusJson,
      settingsJson: settingsJson ?? this.settingsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  // To JSON (for remote)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'parent_collection_id': parentCollectionId,
      'name': name,
      'description': description,
      'icon_json': iconJson,
      'background_json': backgroundJson,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'position': position,
      'layout_type': layoutType,
      'sort_order': sortOrder,
      'visibility': visibility,
      'url_count': urlCount,
      'total_clicks': totalClicks,
      'status_json': statusJson,
      'settings_json': settingsJson,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
    };
  }

  // From JSON (remote)
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      userId: json['user_id'],
      parentCollectionId: json['parent_collection_id'],
      name: json['name'],
      description: json['description'],
      iconJson: json['icon_json'],
      backgroundJson: json['background_json'],
      isPinned: json['is_pinned'],
      isArchived: json['is_archived'],
      position: json['position'],
      layoutType: json['layout_type'],
      sortOrder: json['sort_order'],
      visibility: json['visibility'],
      urlCount: json['url_count'],
      totalClicks: json['total_clicks'],
      statusJson: json['status_json'],
      settingsJson: json['settings_json'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'])
          : null,
    );
  }
}
