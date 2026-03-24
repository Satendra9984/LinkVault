import 'package:equatable/equatable.dart';
import '../../../domain/entities/item.dart';

/// Holds all raw UI inputs for the item form.
/// Following the Form BLoC pattern: this is the single source of truth.
/// The screen owns ZERO controllers.
class ItemFormState extends Equatable {
  final String title;
  final String? description;
  final String? link;
  final String? location;
  final String? tags; // Comma-separated: "coffee, cafe, cozy"
  final String? imagePath;
  final ItemStatus status;

  /// Which "More fields" pills are currently expanded (e.g. {'link', 'location'})
  final Set<String> expandedFields;

  /// Dynamic custom fields added by the user
  final Map<String, CustomField> customFields;

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool isInit; // true while loading an existing item for edit mode

  const ItemFormState({
    this.title = '',
    this.description,
    this.link,
    this.location,
    this.tags,
    this.imagePath,
    this.status = ItemStatus.pending,
    this.expandedFields = const {},
    this.customFields = const {},
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
    String? location,
    bool? clearLocation,
    String? tags,
    bool? clearTags,
    String? imagePath,
    bool? clearImagePath,
    ItemStatus? status,
    Set<String>? expandedFields,
    Map<String, CustomField>? customFields,
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
      location: clearLocation == true ? null : (location ?? this.location),
      tags: clearTags == true ? null : (tags ?? this.tags),
      imagePath: clearImagePath == true ? null : (imagePath ?? this.imagePath),
      status: status ?? this.status,
      expandedFields: expandedFields ?? this.expandedFields,
      customFields: customFields ?? this.customFields,
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
        location,
        tags,
        imagePath,
        status,
        expandedFields,
        customFields,
        isSubmitting,
        isSuccess,
        errorMessage,
        fieldErrors,
        isInit,
      ];
}
