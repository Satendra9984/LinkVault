

import 'package:equatable/equatable.dart';

class SearchHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String query;
  final int resultCount;
  final DateTime createdAt;

  const SearchHistoryEntity({
    required this.id,
    required this.userId,
    required this.query,
    required this.resultCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, query, resultCount, createdAt];
}