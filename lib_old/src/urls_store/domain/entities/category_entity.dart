import 'package:equatable/equatable.dart';
import 'package:link_vault/src/urls_store/domain/entities/icon_data_entity.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String color;
  final IconDataModel icon;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, name, description, color, icon, position, createdAt, updatedAt];
}