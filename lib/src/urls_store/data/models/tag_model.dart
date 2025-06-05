import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/tag_entity.dart';

part 'tag_model.g.dart';

@Collection()
class TagModel {
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

  // Entity to Model
  factory TagModel.fromEntity(TagEntity e) {
    return TagModel(
      id: e.id,
      userId: e.userId,
      name: e.name,
      usageCount: e.usageCount,
      createdAt: e.createdAt,
    );
  }

  // Model to Entity
  TagEntity toEntity() {
    return TagEntity(
      id: id,
      userId: userId,
      name: name,
      usageCount: usageCount,
      createdAt: createdAt,
    );
  }

  // copyWith method
  TagModel copyWith({
    Id? isarId,
    String? id,
    String? userId,
    String? name,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return TagModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // toJson (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // fromJson (snake_case)
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      usageCount: json['usage_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
