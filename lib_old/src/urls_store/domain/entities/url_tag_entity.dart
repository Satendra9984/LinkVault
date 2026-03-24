

import 'package:equatable/equatable.dart';

class UrlTagEntity extends Equatable {
  final String urlId;
  final String tagId;
  final DateTime createdAt;

  const UrlTagEntity({
    required this.urlId,
    required this.tagId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [urlId, tagId, createdAt];
}