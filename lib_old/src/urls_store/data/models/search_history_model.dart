import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/search_history_entity.dart';

part 'search_history_model.g.dart';

@Collection()
class SearchHistoryModel {
  SearchHistoryModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.userId,
    required this.query,
    required this.resultCount,
    required this.createdAt,
  });

  final Id isarId;

  @Index()
  final String id;

  @Index()
  final String userId;

  @Index()
  final String query;

  @Index()
  final int resultCount;

  @Index()
  final DateTime createdAt;

  /// Convert from entity
  factory SearchHistoryModel.fromEntity(SearchHistoryEntity e) {
    return SearchHistoryModel(
      id: e.id,
      userId: e.userId,
      query: e.query,
      resultCount: e.resultCount,
      createdAt: e.createdAt,
    );
  }

  /// Convert to entity
  SearchHistoryEntity toEntity() {
    return SearchHistoryEntity(
      id: id,
      userId: userId,
      query: query,
      resultCount: resultCount,
      createdAt: createdAt,
    );
  }

  /// CopyWith for immutability
  SearchHistoryModel copyWith({
    Id? isarId,
    String? id,
    String? userId,
    String? query,
    int? resultCount,
    DateTime? createdAt,
  }) {
    return SearchHistoryModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      query: query ?? this.query,
      resultCount: resultCount ?? this.resultCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for remote DB (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'query': query,
      'result_count': resultCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert from JSON (snake_case)
  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      query: json['query'] as String,
      resultCount: json['result_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
