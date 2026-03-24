import 'package:equatable/equatable.dart';

class CollectionCategoryEntity extends Equatable {
  final String collectionId;
  final String categoryId;
  final DateTime createdAt;

  const CollectionCategoryEntity({
    required this.collectionId,
    required this.categoryId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [collectionId, categoryId, createdAt];
}

