import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/url_entity.dart';

part 'url_model.g.dart';


@Collection()
class UrlModel extends Equatable {
  UrlModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.collectionId,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.faviconUrl,
    this.dominantColor,
    required this.position,
    required this.isPinned,
    required this.isArchived,
    required this.clickCount,
    required this.metadataJson,
    required this.settingsJson,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
  });

   
  final Id isarId;
  @Index()
  final String id;
  @Index()
  final String collectionId;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final String? dominantColor;
  @Index()
  final int position;
  @Index()
  final bool isPinned;
  @Index()
  final bool isArchived;
  final int clickCount;
  final String metadataJson;
  final String settingsJson;
  @Index()
  final DateTime createdAt;
  @Index()
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;

  @override
  List<Object?> get props => [
        isarId,
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
        metadataJson,
        settingsJson,
        createdAt,
        updatedAt,
        lastAccessedAt
      ];

  factory UrlModel.fromEntity(UrlEntity e) {
    return UrlModel(
      id: e.id,
      collectionId: e.collectionId,
      url: e.url,
      title: e.title,
      description: e.description,
      thumbnailUrl: e.thumbnailUrl,
      faviconUrl: e.faviconUrl,
      position: e.position,
      isPinned: e.isPinned,
      isArchived: e.isArchived,
      clickCount: e.clickCount,
      metadataJson: e.metadata.toString(),
      settingsJson: e.settings.toString(),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      lastAccessedAt: e.lastAccessedAt,
    );
  }

  UrlEntity toEntity() {
    return UrlEntity(
      id: id,
      collectionId: collectionId,
      url: url,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      faviconUrl: faviconUrl,
      position: position,
      isPinned: isPinned,
      isArchived: isArchived,
      clickCount: clickCount,
      metadata: {},
      settings: {},
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastAccessedAt: lastAccessedAt,
    );
  }
}