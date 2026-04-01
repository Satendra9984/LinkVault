import 'entities/item.dart';

/// Client-facing sort modes for URL lists (hub + filter sheet).
enum UrlSortOption {
  position,
  dateAdded,
  dateEdited,
  mostVisited,
  alphabeticalAsc,
  alphabeticalDesc,
}

/// Stable comparison for in-memory tweaks (e.g. optimistic insert); primary
/// ordering should match repository queries for the same [UrlSortOption].
int compareItemsByUrlSort(UrlSortOption sort, Item a, Item b) {
  final primary = switch (sort) {
    UrlSortOption.position => a.position.compareTo(b.position),
    UrlSortOption.dateAdded => b.createdAt.compareTo(a.createdAt),
    UrlSortOption.dateEdited => b.updatedAt.compareTo(a.updatedAt),
    UrlSortOption.mostVisited => b.clickCount.compareTo(a.clickCount),
    UrlSortOption.alphabeticalAsc =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    UrlSortOption.alphabeticalDesc =>
      b.title.toLowerCase().compareTo(a.title.toLowerCase()),
  };
  if (primary != 0) return primary;
  return a.id.compareTo(b.id);
}
