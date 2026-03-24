import 'package:equatable/equatable.dart';

class CollectionTagEntity extends Equatable {
  final String collectionId;
  final String tagId;
  final DateTime createdAt;

  const CollectionTagEntity({
    required this.collectionId,
    required this.tagId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [collectionId, tagId, createdAt];
}