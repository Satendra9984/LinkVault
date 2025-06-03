import 'package:equatable/equatable.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_background.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_icon.dart';
import 'package:link_vault/src/urls_store/domain/entities/url_entity.dart';

class CollectionEntity extends Equatable {
  final String id;
  final String userId;
  final String? parentCollectionId;
  final String name;
  final String? description;
  final CollectionIcon icon;
  final CollectionBackground background;
  final bool isPinned;
  final bool isArchived;
  final int position;
  final String layoutType;
  final String sortOrder;
  final String visibility;
  final Map<String, dynamic> status;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;
  final List<UrlEntity> urls; // For offline-first caching
  final List<CollectionEntity> subCollections; // For nested structure

  const CollectionEntity({
    required this.id,
    required this.userId,
    this.parentCollectionId,
    required this.name,
    this.description,
    required this.icon,
    required this.background,
    this.isPinned = false,
    this.isArchived = false,
    this.position = 0,
    this.layoutType = 'grid',
    this.sortOrder = 'manual',
    this.visibility = 'private',
    this.status = const {},
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
    this.urls = const [],
    this.subCollections = const [],
  });

  // Helper methods
  bool get isRootCollection => parentCollectionId == null;
  int get urlCount => status['url_count'] ?? urls.length;
  int get usageCount => status['usage_count'] ?? 0;

  CollectionEntity copyWith({
    String? id,
    String? userId,
    String? parentCollectionId,
    String? name,
    String? description,
    CollectionIcon? icon,
    CollectionBackground? background,
    bool? isPinned,
    bool? isArchived,
    int? position,
    String? layoutType,
    String? sortOrder,
    String? visibility,
    Map<String, dynamic>? status,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    List<UrlEntity>? urls,
    List<CollectionEntity>? subCollections,
  }) {
    return CollectionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentCollectionId: parentCollectionId ?? this.parentCollectionId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      background: background ?? this.background,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      position: position ?? this.position,
      layoutType: layoutType ?? this.layoutType,
      sortOrder: sortOrder ?? this.sortOrder,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      urls: urls ?? this.urls,
      subCollections: subCollections ?? this.subCollections,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        parentCollectionId,
        name,
        description,
        icon,
        background,
        isPinned,
        isArchived,
        position,
        layoutType,
        sortOrder,
        visibility,
        status,
        settings,
        createdAt,
        updatedAt,
        lastAccessedAt,
      ];
}