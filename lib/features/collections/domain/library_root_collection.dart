import 'entities/collection.dart';

/// Canonical persisted library root: one collection per user with [parentId] null.
/// All other folders are nested under this node.
abstract final class LibraryRootCollection {
  LibraryRootCollection._();

  static const String defaultTitle = 'Library';
  static const String defaultCategory = 'general';
  static const String defaultIcon = '📚';

  /// Legacy ObjectBox / UI sentinel IDs for "uncategorized" links before root existed.
  static const Set<String> legacyRootItemCollectionIds = {'root', 'ROOT'};

  /// Whether [collectionId] is a legacy virtual root for stored items.
  static bool isLegacyRootItemCollectionId(String? collectionId) {
    if (collectionId == null) return false;
    return legacyRootItemCollectionIds.contains(collectionId.trim());
  }

  /// When the data model is healthy, exactly one non-deleted row has a null parent.
  static String? libraryRootIdIfExactlyOne(List<Collection> all) {
    final tops = all
        .where(
          (c) =>
              !c.isDeleted &&
              (c.parentId == null || c.parentId!.trim().isEmpty),
        )
        .toList();
    if (tops.length != 1) return null;
    return tops.single.id;
  }

  static bool isLibraryRoot(Collection c, List<Collection> all) {
    final id = libraryRootIdIfExactlyOne(all);
    return id != null && id == c.id;
  }
}
