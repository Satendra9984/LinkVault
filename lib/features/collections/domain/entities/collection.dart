import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String? ownerId;
  final String? parentId;
  final bool isShared;
  final String title;
  final String category;
  final String colorHex;
  final String iconName;
  final double position;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final int childCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;

  const Collection({
    this.id = '',
    this.ownerId,
    this.parentId,
    this.isShared = false,
    required this.title,
    required this.category,
    required this.colorHex,
    required this.iconName,
    required this.position,
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.childCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        parentId,
        isShared,
        title,
        category,
        colorHex,
        iconName,
        position,
        isPinned,
        isArchived,
        isDeleted,
        childCount,
        createdAt,
        updatedAt,
        itemCount,
      ];
}
