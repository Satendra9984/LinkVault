import 'entities/collection.dart';

/// Sprint 5-6 default ordering within the same [Collection.parentId] scope.
///
/// See [Sprint_5_6_Collections_Architecture.md]: archived last, pinned first,
/// then [Collection.position], then [Collection.updatedAt] tie-break.
int compareCollectionsSiblings(Collection a, Collection b) {
  if (a.isArchived != b.isArchived) {
    return a.isArchived ? 1 : -1;
  }
  if (a.isPinned != b.isPinned) {
    return a.isPinned ? -1 : 1;
  }
  final byPos = a.position.compareTo(b.position);
  if (byPos != 0) return byPos;
  return b.updatedAt.compareTo(a.updatedAt);
}

void sortCollectionsSiblings(List<Collection> list) {
  list.sort(compareCollectionsSiblings);
}
