

import 'package:equatable/equatable.dart';

class RecentActivityEntity extends Equatable {
  final String id;
  final String userId;
  final String activityType;
  final String entityId;
  final String entityType;
  final String? entityName;
  final DateTime createdAt;

  const RecentActivityEntity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.entityId,
    required this.entityType,
    this.entityName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, activityType, entityId, entityType, entityName, createdAt];
}
