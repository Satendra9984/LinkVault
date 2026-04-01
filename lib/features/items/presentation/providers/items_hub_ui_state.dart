import 'items_list_models.dart';

class ItemsHubUiState {
  final bool isReorderMode;
  final String urlSearchQuery;
  final String childSearchQuery;
  final String urlDomainQuery;
  final bool urlPinnedOnly;
  final bool urlWithDescriptionOnly;
  final bool urlWithImageOnly;
  final DateTime? urlSavedAfter;
  final DateTime? urlSavedBefore;
  final ChildFolderSort childFolderSort;
  final bool childIncludeArchived;
  final Set<String> childSelectedCategories;
  final DateTime? childUpdatedAfter;
  final DateTime? childUpdatedBefore;

  const ItemsHubUiState({
    this.isReorderMode = false,
    this.urlSearchQuery = '',
    this.childSearchQuery = '',
    this.urlDomainQuery = '',
    this.urlPinnedOnly = false,
    this.urlWithDescriptionOnly = false,
    this.urlWithImageOnly = false,
    this.urlSavedAfter,
    this.urlSavedBefore,
    this.childFolderSort = ChildFolderSort.titleAsc,
    this.childIncludeArchived = false,
    this.childSelectedCategories = const <String>{},
    this.childUpdatedAfter,
    this.childUpdatedBefore,
  });

  ItemsHubUiState copyWith({
    bool? isReorderMode,
    String? urlSearchQuery,
    String? childSearchQuery,
    String? urlDomainQuery,
    bool? urlPinnedOnly,
    bool? urlWithDescriptionOnly,
    bool? urlWithImageOnly,
    DateTime? urlSavedAfter,
    bool clearUrlSavedAfter = false,
    DateTime? urlSavedBefore,
    bool clearUrlSavedBefore = false,
    ChildFolderSort? childFolderSort,
    bool? childIncludeArchived,
    Set<String>? childSelectedCategories,
    DateTime? childUpdatedAfter,
    bool clearChildUpdatedAfter = false,
    DateTime? childUpdatedBefore,
    bool clearChildUpdatedBefore = false,
  }) {
    return ItemsHubUiState(
      isReorderMode: isReorderMode ?? this.isReorderMode,
      urlSearchQuery: urlSearchQuery ?? this.urlSearchQuery,
      childSearchQuery: childSearchQuery ?? this.childSearchQuery,
      urlDomainQuery: urlDomainQuery ?? this.urlDomainQuery,
      urlPinnedOnly: urlPinnedOnly ?? this.urlPinnedOnly,
      urlWithDescriptionOnly:
          urlWithDescriptionOnly ?? this.urlWithDescriptionOnly,
      urlWithImageOnly: urlWithImageOnly ?? this.urlWithImageOnly,
      urlSavedAfter:
          clearUrlSavedAfter ? null : (urlSavedAfter ?? this.urlSavedAfter),
      urlSavedBefore:
          clearUrlSavedBefore ? null : (urlSavedBefore ?? this.urlSavedBefore),
      childFolderSort: childFolderSort ?? this.childFolderSort,
      childIncludeArchived: childIncludeArchived ?? this.childIncludeArchived,
      childSelectedCategories:
          childSelectedCategories ?? this.childSelectedCategories,
      childUpdatedAfter: clearChildUpdatedAfter
          ? null
          : (childUpdatedAfter ?? this.childUpdatedAfter),
      childUpdatedBefore: clearChildUpdatedBefore
          ? null
          : (childUpdatedBefore ?? this.childUpdatedBefore),
    );
  }
}
