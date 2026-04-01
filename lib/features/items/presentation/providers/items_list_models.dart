import '../../domain/entities/item.dart';
import '../../domain/url_sort_option.dart';

enum UnifiedTab { childCollections, urls }

enum UrlViewMode { list, cards, icons }

/// Sort order for nested folder lists (client-side).
enum ChildFolderSort {
  titleAsc,
  titleDesc,
  itemCountDesc,
  createdDesc,
  updatedDesc,
}

/// Links tab data: lazy-loaded when user switches to Links (or [ensureUrlsLoaded]).
enum UrlsDataPhase {
  notStarted,
  loading,
  loaded,
  error,
}

class ItemsState {
  static const Object _kUnset = Object();

  final List<Item> items;
  final bool hasMore;
  final bool isLoadingMore;
  final ItemStatus? statusFilter;
  final UrlSortOption sortOption;
  final UrlViewMode viewMode;
  final UnifiedTab activeTab;
  final UrlsDataPhase urlsDataPhase;
  final String? urlsErrorMessage;

  /// Next offset for pagination (sum of item counts returned so far).
  final int fetchedCount;

  ItemsState({
    required this.items,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.statusFilter,
    this.sortOption = UrlSortOption.dateAdded,
    this.viewMode = UrlViewMode.list,
    this.activeTab = UnifiedTab.childCollections,
    this.urlsDataPhase = UrlsDataPhase.notStarted,
    this.urlsErrorMessage,
    this.fetchedCount = 0,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? hasMore,
    bool? isLoadingMore,
    ItemStatus? statusFilter,
    UrlSortOption? sortOption,
    UrlViewMode? viewMode,
    UnifiedTab? activeTab,
    UrlsDataPhase? urlsDataPhase,
    Object? urlsErrorMessage = _kUnset,
    int? fetchedCount,
  }) {
    return ItemsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter: statusFilter ?? this.statusFilter,
      sortOption: sortOption ?? this.sortOption,
      viewMode: viewMode ?? this.viewMode,
      activeTab: activeTab ?? this.activeTab,
      urlsDataPhase: urlsDataPhase ?? this.urlsDataPhase,
      urlsErrorMessage: urlsErrorMessage == _kUnset
          ? this.urlsErrorMessage
          : urlsErrorMessage as String?,
      fetchedCount: fetchedCount ?? this.fetchedCount,
    );
  }
}
