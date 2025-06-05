

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/tag_entity.dart';

@Collection()
class TagModel extends Equatable {
  TagModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.userId,
    required this.name,
    required this.usageCount,
    required this.createdAt,
  });

   
  final Id isarId;
  @Index()
  final String id;
  @Index()
  final String userId;
  @Index()
  final String name;
  @Index()
  final int usageCount;
  @Index()
  final DateTime createdAt;

  @override
  List<Object?> get props => [isarId, id, userId, name, usageCount, createdAt];

  factory TagModel.fromEntity(TagEntity e) {
    return TagModel(
      id: e.id,
      userId: e.userId,
      name: e.name,
      usageCount: e.usageCount,
      createdAt: e.createdAt,
    );
  }

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      userId: userId,
      name: name,
      usageCount: usageCount,
      createdAt: createdAt,
    );
  }
}
