import 'package:equatable/equatable.dart';

class UrlEntity extends Equatable {
  final String id;
  final String collectionId;
  final String userId;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final int position;
  final bool isPinned; // This is your "favourite" feature
  final int clickCount;
  final DateTime? lastClickedAt;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UrlEntity({
    required this.id,
    required this.collectionId,
    required this.userId,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.faviconUrl,
    this.position = 0,
    this.isPinned = false,
    this.clickCount = 0,
    this.lastClickedAt,
    this.metadata = const {},
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt, required bool isArchived, DateTime? lastAccessedAt,
  });

  bool get isFavourite => isPinned;
  bool get hasBeenClicked => lastClickedAt != null;
  
  UrlEntity copyWith({
    String? id,
    String? collectionId,
    String? userId,
    String? url,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? faviconUrl,
    int? position,
    bool? isPinned,
    int? clickCount,
    DateTime? lastClickedAt,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UrlEntity(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      position: position ?? this.position,
      isPinned: isPinned ?? this.isPinned,
      clickCount: clickCount ?? this.clickCount,
      lastClickedAt: lastClickedAt ?? this.lastClickedAt,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        collectionId,
        userId,
        url,
        title,
        description,
        thumbnailUrl,
        faviconUrl,
        position,
        isPinned,
        clickCount,
        lastClickedAt,
        metadata,
        settings,
        createdAt,
        updatedAt,
      ];
}
