



import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/search_history_entity.dart';

@Collection()
class SearchHistoryModel extends Equatable {
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

  @override
  List<Object?> get props => [isarId, id, userId, query, resultCount, createdAt];

  factory SearchHistoryModel.fromEntity(SearchHistoryEntity e) {
    return SearchHistoryModel(
      id: e.id,
      userId: e.userId,
      query: e.query,
      resultCount: e.resultCount,
      createdAt: e.createdAt,
    );
  }

  SearchHistoryEntity toEntity() {
    return SearchHistoryEntity(
      id: id,
      userId: userId,
      query: query,
      resultCount: resultCount,
      createdAt: createdAt,
    );
  }
}