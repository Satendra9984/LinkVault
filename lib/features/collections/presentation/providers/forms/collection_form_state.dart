import 'package:equatable/equatable.dart';

import '../../../domain/collection_display_defaults.dart';

class _Unset {
  const _Unset();
}

const _unset = _Unset();

class CollectionFormState extends Equatable {
  final String title;
  final String description;
  final String category;
  final String iconName;
  final String colorHex;
  final String? parentId;
  /// Shown in the parent row when creating under a known folder.
  final String? parentTitleHint;
  final bool isPinned;
  final bool isArchived;
  final bool isShared;
  final String itemsLayout;
  final String childCollectionsLayout;
  final String itemsSortDefault;
  final String openLinksIn;
  final bool showLinkPreviews;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage; // For global/network errors
  final Map<String, String> fieldErrors; // For specific field validation errors
  final bool isInit; // Useful for knowing if we've loaded existing data
  /// When true, [category] / [iconName] are user-defined (not a preset label).
  final bool usesCustomCategory;

  const CollectionFormState({
    this.title = '',
    this.description = '',
    this.category = 'Favorites',
    this.iconName = '⭐',
    this.colorHex = '#B3E0FF',
    this.parentId,
    this.parentTitleHint,
    this.isPinned = false,
    this.isArchived = false,
    this.isShared = false,
    this.itemsLayout = CollectionLayoutMode.compactGrid,
    this.childCollectionsLayout = CollectionLayoutMode.compactGrid,
    this.itemsSortDefault = CollectionItemsSortDefault.manual,
    this.openLinksIn = CollectionOpenLinksIn.inApp,
    this.showLinkPreviews = true,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.isInit = true,
    this.usesCustomCategory = false,
  });

  CollectionFormState copyWith({
    String? title,
    String? description,
    String? category,
    String? iconName,
    String? colorHex,
    String? parentId,
    Object? parentTitleHint = _unset,
    bool? isPinned,
    bool? isArchived,
    bool? isShared,
    String? itemsLayout,
    String? childCollectionsLayout,
    String? itemsSortDefault,
    String? openLinksIn,
    bool? showLinkPreviews,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? isInit,
    bool? usesCustomCategory,
  }) {
    return CollectionFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      parentId: parentId ?? this.parentId,
      parentTitleHint: identical(parentTitleHint, _unset)
          ? this.parentTitleHint
          : parentTitleHint as String?,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isShared: isShared ?? this.isShared,
      itemsLayout: itemsLayout ?? this.itemsLayout,
      childCollectionsLayout:
          childCollectionsLayout ?? this.childCollectionsLayout,
      itemsSortDefault: itemsSortDefault ?? this.itemsSortDefault,
      openLinksIn: openLinksIn ?? this.openLinksIn,
      showLinkPreviews: showLinkPreviews ?? this.showLinkPreviews,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage, // Note: Intentionally allowing nullification
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isInit: isInit ?? this.isInit,
      usesCustomCategory: usesCustomCategory ?? this.usesCustomCategory,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        iconName,
        colorHex,
        parentId,
        parentTitleHint,
        isPinned,
        isArchived,
        isShared,
        itemsLayout,
        childCollectionsLayout,
        itemsSortDefault,
        openLinksIn,
        showLinkPreviews,
        isSubmitting,
        isSuccess,
        errorMessage,
        fieldErrors,
        isInit,
        usesCustomCategory,
      ];
}
