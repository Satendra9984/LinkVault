import '../../../../items/domain/entities/item.dart';
import '../../../../items/domain/url_sort_option.dart';
import '../../../../items/presentation/providers/items_list_models.dart';

/// Bottom tabs on the global search screen (parity with Items hub).
enum GlobalSearchTab {
  collections,
  links,
}

/// Riverpod state for `/search`: per-tab queries and filters.
class GlobalSearchState {
  const GlobalSearchState({
    this.activeTab = GlobalSearchTab.collections,
    this.collectionsSearchDraft = '',
    this.collectionsCommittedQuery = '',
    this.collectionsShowOnlyPrivate = false,
    this.collectionsFolderSort = ChildFolderSort.titleAsc,
    this.collectionsIncludeArchived = false,
    this.collectionsSelectedCategories = const <String>{},
    this.collectionsUpdatedAfter,
    this.collectionsUpdatedBefore,
    this.collectionsViewMode = UrlViewMode.icons,
    this.linksSearchDraft = '',
    this.linksCommittedQuery = '',
    this.linksViewMode = UrlViewMode.icons,
    this.linksSortOption = UrlSortOption.dateAdded,
    this.linksStatusFilter,
    this.linksPinnedOnly = false,
    this.linksWithDescriptionOnly = false,
    this.linksWithImageOnly = false,
    this.linksDomainQuery = '',
    this.linksSavedAfter,
    this.linksSavedBefore,
  });

  final GlobalSearchTab activeTab;

  /// Collections tab: manual draft/commit parity with Links.
  final String collectionsSearchDraft;
  final String collectionsCommittedQuery;
  final bool collectionsShowOnlyPrivate;
  final ChildFolderSort collectionsFolderSort;
  final bool collectionsIncludeArchived;
  final Set<String> collectionsSelectedCategories;
  final DateTime? collectionsUpdatedAfter;
  final DateTime? collectionsUpdatedBefore;

  /// Layout for the Collections tab (list / grid / icons). Controlled via filters screen.
  final UrlViewMode collectionsViewMode;

  /// Links tab: draft vs committed query (hub Links parity — manual search).
  final String linksSearchDraft;
  final String linksCommittedQuery;
  final UrlViewMode linksViewMode;
  final UrlSortOption linksSortOption;
  final ItemStatus? linksStatusFilter;
  final bool linksPinnedOnly;
  final bool linksWithDescriptionOnly;
  final bool linksWithImageOnly;
  final String linksDomainQuery;
  final DateTime? linksSavedAfter;
  final DateTime? linksSavedBefore;

  bool get collectionsFiltersActive =>
      collectionsShowOnlyPrivate ||
      collectionsFolderSort != ChildFolderSort.titleAsc ||
      collectionsIncludeArchived ||
      collectionsSelectedCategories.isNotEmpty ||
      collectionsUpdatedAfter != null ||
      collectionsUpdatedBefore != null ||
      collectionsViewMode != UrlViewMode.icons;

  bool get linksFiltersActive =>
      linksStatusFilter != null ||
      linksSortOption != UrlSortOption.dateAdded ||
      linksViewMode != UrlViewMode.icons ||
      linksPinnedOnly ||
      linksWithDescriptionOnly ||
      linksWithImageOnly ||
      linksDomainQuery.trim().isNotEmpty ||
      linksSavedAfter != null ||
      linksSavedBefore != null;

  GlobalSearchState copyWith({
    GlobalSearchTab? activeTab,
    String? collectionsSearchDraft,
    String? collectionsCommittedQuery,
    bool? collectionsShowOnlyPrivate,
    ChildFolderSort? collectionsFolderSort,
    bool? collectionsIncludeArchived,
    Set<String>? collectionsSelectedCategories,
    DateTime? collectionsUpdatedAfter,
    bool clearCollectionsUpdatedAfter = false,
    DateTime? collectionsUpdatedBefore,
    bool clearCollectionsUpdatedBefore = false,
    UrlViewMode? collectionsViewMode,
    String? linksSearchDraft,
    String? linksCommittedQuery,
    UrlViewMode? linksViewMode,
    UrlSortOption? linksSortOption,
    ItemStatus? linksStatusFilter,
    bool clearLinksStatusFilter = false,
    bool? linksPinnedOnly,
    bool? linksWithDescriptionOnly,
    bool? linksWithImageOnly,
    String? linksDomainQuery,
    DateTime? linksSavedAfter,
    bool clearLinksSavedAfter = false,
    DateTime? linksSavedBefore,
    bool clearLinksSavedBefore = false,
  }) {
    return GlobalSearchState(
      activeTab: activeTab ?? this.activeTab,
      collectionsSearchDraft:
          collectionsSearchDraft ?? this.collectionsSearchDraft,
      collectionsCommittedQuery:
          collectionsCommittedQuery ?? this.collectionsCommittedQuery,
      collectionsShowOnlyPrivate:
          collectionsShowOnlyPrivate ?? this.collectionsShowOnlyPrivate,
      collectionsFolderSort:
          collectionsFolderSort ?? this.collectionsFolderSort,
      collectionsIncludeArchived:
          collectionsIncludeArchived ?? this.collectionsIncludeArchived,
      collectionsSelectedCategories:
          collectionsSelectedCategories ?? this.collectionsSelectedCategories,
      collectionsUpdatedAfter: clearCollectionsUpdatedAfter
          ? null
          : (collectionsUpdatedAfter ?? this.collectionsUpdatedAfter),
      collectionsUpdatedBefore: clearCollectionsUpdatedBefore
          ? null
          : (collectionsUpdatedBefore ?? this.collectionsUpdatedBefore),
      collectionsViewMode: collectionsViewMode ?? this.collectionsViewMode,
      linksSearchDraft: linksSearchDraft ?? this.linksSearchDraft,
      linksCommittedQuery: linksCommittedQuery ?? this.linksCommittedQuery,
      linksViewMode: linksViewMode ?? this.linksViewMode,
      linksSortOption: linksSortOption ?? this.linksSortOption,
      linksStatusFilter: clearLinksStatusFilter
          ? null
          : (linksStatusFilter ?? this.linksStatusFilter),
      linksPinnedOnly: linksPinnedOnly ?? this.linksPinnedOnly,
      linksWithDescriptionOnly:
          linksWithDescriptionOnly ?? this.linksWithDescriptionOnly,
      linksWithImageOnly: linksWithImageOnly ?? this.linksWithImageOnly,
      linksDomainQuery: linksDomainQuery ?? this.linksDomainQuery,
      linksSavedAfter:
          clearLinksSavedAfter ? null : (linksSavedAfter ?? this.linksSavedAfter),
      linksSavedBefore: clearLinksSavedBefore
          ? null
          : (linksSavedBefore ?? this.linksSavedBefore),
    );
  }
}
