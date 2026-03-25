import 'package:equatable/equatable.dart';

import '../../../domain/entities/item.dart';

/// Holds all raw UI inputs for the URL item form.
///
/// Controllerless MVVM: the screen owns ZERO controllers — this is the
/// single source of truth.
class ItemFormState extends Equatable {
  final String title;
  final String? description;
  final String? link;

  /// Notes (maps to `lv_urls.annotation`).
  final String? annotation;

  final String? tags; // Comma-separated: "coffee, cafe, cozy"
  final String? imagePath;

  /// Remote preview thumbnail URL (derived from link parsing).
  final String? imageUrl;

  final String? faviconUrl;
  final String? siteName;

  // Future fields (recommended)
  final String? canonicalUrl;
  final String? contentType;
  final DateTime? publishedAt;

  final ItemStatus status;

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool isInit; // true while loading an existing item for edit mode

  const ItemFormState({
    this.title = '',
    this.description,
    this.link,
    this.annotation,
    this.tags,
    this.imagePath,
    this.imageUrl,
    this.faviconUrl,
    this.siteName,
    this.canonicalUrl,
    this.contentType,
    this.publishedAt,
    this.status = ItemStatus.unread,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.isInit = true,
  });

  ItemFormState copyWith({
    String? title,
    String? description,
    bool? clearDescription,
    String? link,
    bool? clearLink,
    String? annotation,
    bool? clearAnnotation,
    String? tags,
    bool? clearTags,
    String? imagePath,
    bool? clearImagePath,
    String? imageUrl,
    bool? clearImageUrl,
    String? faviconUrl,
    bool? clearFaviconUrl,
    String? siteName,
    bool? clearSiteName,
    String? canonicalUrl,
    bool? clearCanonicalUrl,
    String? contentType,
    bool? clearContentType,
    DateTime? publishedAt,
    bool? clearPublishedAt,
    ItemStatus? status,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? isInit,
  }) {
    return ItemFormState(
      title: title ?? this.title,
      description:
          clearDescription == true ? null : (description ?? this.description),
      link: clearLink == true ? null : (link ?? this.link),
      annotation:
          clearAnnotation == true ? null : (annotation ?? this.annotation),
      tags: clearTags == true ? null : (tags ?? this.tags),
      imagePath: clearImagePath == true ? null : (imagePath ?? this.imagePath),
      imageUrl: clearImageUrl == true ? null : (imageUrl ?? this.imageUrl),
      faviconUrl:
          clearFaviconUrl == true ? null : (faviconUrl ?? this.faviconUrl),
      siteName: clearSiteName == true ? null : (siteName ?? this.siteName),
      canonicalUrl: clearCanonicalUrl == true
          ? null
          : (canonicalUrl ?? this.canonicalUrl),
      contentType: clearContentType == true
          ? null
          : (contentType ?? this.contentType),
      publishedAt: clearPublishedAt == true ? null : (publishedAt ?? this.publishedAt),
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isInit: isInit ?? this.isInit,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        link,
        annotation,
        tags,
        imagePath,
        imageUrl,
        faviconUrl,
        siteName,
        canonicalUrl,
        contentType,
        publishedAt,
        status,
        isSubmitting,
        isSuccess,
        errorMessage,
        fieldErrors,
        isInit,
      ];
}

