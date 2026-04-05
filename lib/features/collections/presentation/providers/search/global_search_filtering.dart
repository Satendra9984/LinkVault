import '../../../domain/entities/collection.dart';
import '../../../../items/domain/entities/item.dart';
import '../../../../items/domain/url_sort_option.dart';
import '../../../../items/presentation/providers/items_list_models.dart';
import 'global_search_state.dart';

/// Applies hub-style folder filters + text search across **all** collections.
List<Collection> filterAndSortCollectionsForGlobalSearch(
  List<Collection> all,
  GlobalSearchState state,
) {
  final q = state.collectionsCommittedQuery.trim().toLowerCase();
  var filtered = all.where((c) {
    if (c.isDeleted) return false;
    // Exclude root / top-level containers (Library root and system folders).
    if (c.parentId == null || c.parentId!.trim().isEmpty) return false;
    if (state.collectionsShowOnlyPrivate && c.isShared) return false;
    if (!state.collectionsIncludeArchived && c.isArchived) return false;
    if (state.collectionsSelectedCategories.isNotEmpty &&
        !state.collectionsSelectedCategories.contains(c.category)) {
      return false;
    }
    if (state.collectionsUpdatedAfter != null &&
        c.updatedAt.isBefore(state.collectionsUpdatedAfter!)) {
      return false;
    }
    if (state.collectionsUpdatedBefore != null &&
        c.updatedAt.isAfter(state.collectionsUpdatedBefore!)) {
      return false;
    }
    if (q.isEmpty) return true;
    return c.title.toLowerCase().contains(q) ||
        c.category.toLowerCase().contains(q);
  }).toList();

  filtered.sort((a, b) {
    switch (state.collectionsFolderSort) {
      case ChildFolderSort.titleAsc:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case ChildFolderSort.titleDesc:
        return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      case ChildFolderSort.itemCountDesc:
        final byCount = b.itemCount.compareTo(a.itemCount);
        if (byCount != 0) return byCount;
        return a.id.compareTo(b.id);
      case ChildFolderSort.createdDesc:
        final byC = b.createdAt.compareTo(a.createdAt);
        if (byC != 0) return byC;
        return a.id.compareTo(b.id);
      case ChildFolderSort.updatedDesc:
        final byU = b.updatedAt.compareTo(a.updatedAt);
        if (byU != 0) return byU;
        return a.id.compareTo(b.id);
    }
  });

  return filtered;
}

bool _itemMatchesText(Item item, String q) {
  if (q.isEmpty) return true;
  final title = item.title.toLowerCase();
  final link = (item.link ?? '').toLowerCase();
  final description = (item.description ?? '').toLowerCase();
  final tags = (item.tags ?? '').toLowerCase();
  return title.contains(q) ||
      link.contains(q) ||
      description.contains(q) ||
      tags.contains(q);
}

bool _itemMatchesDomain(Item item, String domainTrimmed) {
  if (domainTrimmed.isEmpty) return true;
  final link = item.link?.toLowerCase() ?? '';
  return link.contains(domainTrimmed.toLowerCase());
}

bool _itemMatchesSavedRange(Item item, DateTime? after, DateTime? before) {
  if (after != null) {
    final start = DateTime(after.year, after.month, after.day);
    if (item.createdAt.isBefore(start)) return false;
  }
  if (before != null) {
    final end = DateTime(
      before.year,
      before.month,
      before.day,
      23,
      59,
      59,
      999,
    );
    if (item.createdAt.isAfter(end)) return false;
  }
  return true;
}

/// Applies committed query + URL filter sheet semantics globally (in-memory).
List<Item> filterAndSortLinksForGlobalSearch(
  List<Item> all,
  GlobalSearchState state,
) {
  final q = state.linksCommittedQuery.trim().toLowerCase();
  var filtered = all.where((item) {
    if (item.isDeleted) return false;
    if (!_itemMatchesText(item, q)) return false;
    if (state.linksStatusFilter != null &&
        item.status != state.linksStatusFilter) {
      return false;
    }
    if (state.linksPinnedOnly && !item.isPinned) return false;
    if (state.linksWithDescriptionOnly &&
        (item.description == null || item.description!.trim().isEmpty)) {
      return false;
    }
    if (state.linksWithImageOnly &&
        (item.imageUrl == null || item.imageUrl!.trim().isEmpty) &&
        (item.imagePath == null || item.imagePath!.trim().isEmpty)) {
      return false;
    }
    if (!_itemMatchesDomain(item, state.linksDomainQuery.trim())) {
      return false;
    }
    if (!_itemMatchesSavedRange(
      item,
      state.linksSavedAfter,
      state.linksSavedBefore,
    )) {
      return false;
    }
    return true;
  }).toList();

  filtered.sort((a, b) => compareItemsByUrlSort(state.linksSortOption, a, b));
  return filtered;
}
