import '../entities/item.dart';
import '../url_sort_option.dart';

/// Server-side (or local DB) query for URLs in a single collection.
class UrlItemsQuery {
  const UrlItemsQuery({
    required this.collectionId,
    required this.limit,
    required this.offset,
    this.status,
    this.sort = UrlSortOption.dateAdded,
    this.searchQuery = '',
    this.pinnedOnly = false,
    this.withDescriptionOnly = false,
    this.withImageOnly = false,
    this.domainContains = '',
    this.savedAfter,
    this.savedBefore,
  });

  final String collectionId;
  final int limit;
  final int offset;
  final ItemStatus? status;
  final UrlSortOption sort;

  /// Title / URL substring (case-insensitive in repositories).
  final String searchQuery;
  final bool pinnedOnly;
  final bool withDescriptionOnly;
  final bool withImageOnly;

  /// Substring match against URL (case-insensitive).
  final String domainContains;
  final DateTime? savedAfter;
  final DateTime? savedBefore;
}

/// One page of URL query results.
class UrlItemsPage {
  const UrlItemsPage({
    required this.items,
    required this.hasMore,
  });

  final List<Item> items;
  final bool hasMore;
}
