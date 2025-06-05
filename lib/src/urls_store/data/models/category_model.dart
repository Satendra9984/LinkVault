import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/category_entity.dart';
import 'package:link_vault/src/urls_store/domain/entities/icon_data_entity.dart';

part 'linkvault_models_and_entities.g.dart';

@Collection()
class CategoryModel extends Equatable {
  CategoryModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.color,
    required this.iconJson,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  
  final Id isarId;
  @Index()
  final String id;
  @Index()
  final String userId;
  @Index()
  final String name;
  final String? description;
  final String color;
  final String iconJson;
  @Index()
  final int position;
  @Index()
  final DateTime createdAt;
  @Index()
  final DateTime updatedAt;

  @override
  List<Object?> get props => [isarId, id, userId, name, description, color, iconJson, position, createdAt, updatedAt];

  factory CategoryModel.fromEntity(CategoryEntity e) {
    return CategoryModel(
      id: e.id,
      userId: e.userId,
      name: e.name,
      description: e.description,
      color: e.color,
      iconJson: e.icon.toMap().toString(),
      position: e.position,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      color: color,
      icon: IconDataModel.fromMap({}),
      position: position,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
