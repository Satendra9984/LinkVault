import 'package:equatable/equatable.dart';

/// Domain‐layer representation of a URL in a collection.
/// All fields are immutable, and JSON/string parsing is handled in the data layer.
class UrlEntity extends Equatable {
  final String id;
  final String collectionId;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final String? dominantColor;
  final int position;
  final bool isPinned;
  final bool isArchived;
  final int clickCount;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;

  const UrlEntity({
    required this.id,
    required this.collectionId,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.faviconUrl,
    this.dominantColor,
    this.position = 0,
    this.isPinned = false,
    this.isArchived = false,
    this.clickCount = 0,
    this.metadata = const <String, dynamic>{},
    this.settings = const <String, dynamic>{},
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
  });


  @override
  List<Object?> get props => [
        id,
        collectionId,
        url,
        title,
        description,
        thumbnailUrl,
        faviconUrl,
        dominantColor,
        position,
        isPinned,
        isArchived,
        clickCount,
        metadata,
        settings,
        createdAt,
        updatedAt,
        lastAccessedAt,
      ];
}
