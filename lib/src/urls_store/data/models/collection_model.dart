import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_background.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_entity.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_icon.dart';

part 'linkvault_models_and_entities.g.dart';

@Collection()
class CollectionModel extends Equatable {
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
  final String id;

  @Index()
  final String userId;
  final String? parentCollectionId;
  final String name;
  final String? description;
  final String iconJson;
  final String backgroundJson;
  @Index()
  final bool isPinned;
  @Index()
  final bool isArchived;
  @Index()
  final int position;
  final String layoutType;
  final String sortOrder;
  final String visibility;
  final int urlCount;
  final int totalClicks;
  final String statusJson;
  final String settingsJson;
  @Index()
  final DateTime createdAt;
  @Index()
  final DateTime updatedAt;
  @Index()
  final DateTime lastAccessedAt;

  @override
  List<Object?> get props => [
        isarId,
        id,
        userId,
        parentCollectionId,
        name,
        description,
        iconJson,
        backgroundJson,
        isPinned,
        isArchived,
        position,
        layoutType,
        sortOrder,
        visibility,
        urlCount,
        totalClicks,
        statusJson,
        settingsJson,
        createdAt,
        updatedAt,
        lastAccessedAt
      ];

  factory CollectionModel.fromEntity(CollectionEntity e) {
    return CollectionModel(
      id: e.id,
      userId: e.userId,
      parentCollectionId: e.parentCollectionId,
      name: e.name,
      description: e.description,
      iconJson: e.icon.toJson().toString(),
      backgroundJson: e.background.toJson().toString(),
      isPinned: e.isPinned,
      isArchived: e.isArchived,
      position: e.position,
      layoutType: e.layoutType,
      sortOrder: e.sortOrder,
      visibility: e.visibility,
      urlCount: e.urlCount,
      totalClicks: e.totalClicks,
      statusJson: e.status.toString(),
      settingsJson: e.settings.toString(),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      lastAccessedAt: e.lastAccessedAt,
    );
  }

  CollectionEntity toEntity() {
    // Parsing of JSON strings to maps should be implemented as needed
    return CollectionEntity(
      id: id,
      userId: userId,
      parentCollectionId: parentCollectionId,
      name: name,
      description: description,
      icon: CollectionIcon.fromJson({}),
      background: CollectionBackground.fromJson({}),
      isPinned: isPinned,
      isArchived: isArchived,
      position: position,
      layoutType: layoutType,
      sortOrder: sortOrder,
      visibility: visibility,
      status: {},
      settings: {},
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastAccessedAt: lastAccessedAt,
    );
  }
}
