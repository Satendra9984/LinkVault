import '../../../items/domain/entities/item.dart';
import '../../../items/presentation/providers/items_providers.dart';

class CollectionsListUiState {
  final bool isGrid;
  final String folderSearchQuery;
  final String rootLinksSearchQuery;
  final ItemStatus? rootLinksStatusFilter;
  final UrlViewMode rootLinksViewMode;

  const CollectionsListUiState({
    this.isGrid = true,
    this.folderSearchQuery = '',
    this.rootLinksSearchQuery = '',
    this.rootLinksStatusFilter,
    this.rootLinksViewMode = UrlViewMode.list,
  });

  CollectionsListUiState copyWith({
    bool? isGrid,
    String? folderSearchQuery,
    String? rootLinksSearchQuery,
    ItemStatus? rootLinksStatusFilter,
    bool clearRootLinksStatusFilter = false,
    UrlViewMode? rootLinksViewMode,
  }) {
    return CollectionsListUiState(
      isGrid: isGrid ?? this.isGrid,
      folderSearchQuery: folderSearchQuery ?? this.folderSearchQuery,
      rootLinksSearchQuery: rootLinksSearchQuery ?? this.rootLinksSearchQuery,
      rootLinksStatusFilter: clearRootLinksStatusFilter
          ? null
          : (rootLinksStatusFilter ?? this.rootLinksStatusFilter),
      rootLinksViewMode: rootLinksViewMode ?? this.rootLinksViewMode,
    );
  }
}
