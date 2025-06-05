import 'package:equatable/equatable.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_background.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_icon.dart';

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
  final DateTime lastAccessedAt;

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
    required this.lastAccessedAt,
  });

  // Helper methods
  bool get isRootCollection => parentCollectionId == null;
  int get usageCount => status['usage_count'] ?? 0;

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
        lastAccessedAt
      ];
}
