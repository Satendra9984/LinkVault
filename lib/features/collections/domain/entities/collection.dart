import 'package:equatable/equatable.dart';

import '../collection_display_defaults.dart';

class Collection extends Equatable {
  final String id;
  final String? ownerId;
  final String? parentId;
  final bool isShared;
  final String title;
  final String? description;
  final String category;
  final String colorHex;
  final String iconName;
  /// Optional JSON string for rich icon; when null use [iconName] + [colorHex].
  final String? iconJson;
  final double position;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final int childCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;
  /// Layout for saved links (URLs): `list` | `grid` | `compact_grid`.
  final String itemsLayout;
  /// Layout for nested folder tiles: `list` | `grid` | `compact_grid`.
  final String childCollectionsLayout;
  final String itemsSortDefault;
  final String openLinksIn;
  final bool showLinkPreviews;
  final int itemCount;

  const Collection({
    this.id = '',
    this.ownerId,
    this.parentId,
    this.isShared = false,
    required this.title,
    this.description,
    required this.category,
    required this.colorHex,
    required this.iconName,
    this.iconJson,
    required this.position,
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.childCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
    this.itemsLayout = CollectionLayoutMode.list,
    this.childCollectionsLayout = CollectionLayoutMode.list,
    this.itemsSortDefault = CollectionItemsSortDefault.manual,
    this.openLinksIn = CollectionOpenLinksIn.inApp,
    this.showLinkPreviews = true,
    this.itemCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        parentId,
        isShared,
        title,
        description,
        category,
        colorHex,
        iconName,
        iconJson,
        position,
        isPinned,
        isArchived,
        isDeleted,
        childCount,
        createdAt,
        updatedAt,
        lastAccessedAt,
        itemsLayout,
        childCollectionsLayout,
        itemsSortDefault,
        openLinksIn,
        showLinkPreviews,
        itemCount,
      ];
}
