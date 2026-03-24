import 'package:equatable/equatable.dart';

class CollectionFormState extends Equatable {
  final String title;
  final String category;
  final String iconName;
  final String colorHex;
  final String? parentId;
  final bool isPinned;
  final bool isArchived;
  final bool isShared;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage; // For global/network errors
  final Map<String, String> fieldErrors; // For specific field validation errors
  final bool isInit; // Useful for knowing if we've loaded existing data

  const CollectionFormState({
    this.title = '',
    this.category = 'Favorites',
    this.iconName = 'folder',
    this.colorHex = '#B3E0FF',
    this.parentId,
    this.isPinned = false,
    this.isArchived = false,
    this.isShared = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.isInit = true,
  });

  CollectionFormState copyWith({
    String? title,
    String? category,
    String? iconName,
    String? colorHex,
    String? parentId,
    bool? isPinned,
    bool? isArchived,
    bool? isShared,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? isInit,
  }) {
    return CollectionFormState(
      title: title ?? this.title,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      parentId: parentId ?? this.parentId,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isShared: isShared ?? this.isShared,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage, // Note: Intentionally allowing nullification
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isInit: isInit ?? this.isInit,
    );
  }

  @override
  List<Object?> get props => [
        title,
        category,
        iconName,
        colorHex,
        parentId,
        isPinned,
        isArchived,
        isShared,
        isSubmitting,
        isSuccess,
        errorMessage,
        fieldErrors,
        isInit,
      ];
}
