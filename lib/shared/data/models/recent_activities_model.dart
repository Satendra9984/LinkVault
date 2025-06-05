


import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/shared/domain/entities/recent_activities_entity.dart';

@Collection()
class RecentActivityModel extends Equatable {
  RecentActivityModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.userId,
    required this.activityType,
    required this.entityId,
    required this.entityType,
    this.entityName,
    required this.createdAt,
  });

  @Id()
  final Id isarId;
  @Index()
  final String id;
  @Index()
  final String userId;
  final String activityType;
  final String entityId;
  final String entityType;
  final String? entityName;
  @Index()
  final DateTime createdAt;

  @override
  List<Object?> get props => [isarId, id, userId, activityType, entityId, entityType, entityName, createdAt];

  factory RecentActivityModel.fromEntity(RecentActivityEntity e) {
    return RecentActivityModel(
      id: e.id,
      userId: e.userId,
      activityType: e.activityType,
      entityId: e.entityId,
      entityType: e.entityType,
      entityName: e.entityName,
      createdAt: e.createdAt,
    );
  }

  RecentActivityEntity toEntity() {
    return RecentActivityEntity(
      id: id,
      userId: userId,
      activityType: activityType,
      entityId: entityId,
      entityType: entityType,
      entityName: entityName,
      createdAt: createdAt,
    );
  }
}
