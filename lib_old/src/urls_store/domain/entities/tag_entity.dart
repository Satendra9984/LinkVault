import 'package:equatable/equatable.dart';

class TagEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final int usageCount;
  final DateTime createdAt;

  const TagEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.usageCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, usageCount, createdAt];
}