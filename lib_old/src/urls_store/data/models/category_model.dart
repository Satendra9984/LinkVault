import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/category_entity.dart';
import 'package:link_vault/src/urls_store/domain/entities/icon_data_entity.dart';

part 'category_model.g.dart';

@Collection()
class CategoryModel {
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

  // Convert from Entity to Model
  factory CategoryModel.fromEntity(CategoryEntity e) {
    return CategoryModel(
      id: e.id,
      userId: e.userId,
      name: e.name,
      description: e.description,
      color: e.color,
      iconJson: jsonEncode(e.icon.toMap()),
      position: e.position,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  // Convert from Model to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      color: color,
      icon: IconDataModel.fromMap(jsonDecode(iconJson)),
      position: position,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // CopyWith method
  CategoryModel copyWith({
    Id? isarId,
    String? id,
    String? userId,
    String? name,
    String? description,
    String? color,
    String? iconJson,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconJson: iconJson ?? this.iconJson,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To JSON for remote (snake_case keys)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'color': color,
      'icon_json': iconJson,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // From JSON (snake_case keys)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      iconJson: json['icon_json'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
