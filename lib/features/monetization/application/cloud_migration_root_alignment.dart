import '../../collections/data/mappers/supabase_collection_mapper.dart';
import '../../collections/domain/entities/collection.dart';
import '../../collections/domain/library_root_collection.dart';
import '../../items/domain/entities/item.dart';

/// Pure helpers for guest→cloud migration so we never violate
/// `uq_lv_collections_one_root_per_user` (one non-deleted `parent_id IS NULL`
/// row per `owner_id`).
abstract final class CloudMigrationRootAlignment {
  CloudMigrationRootAlignment._();

  /// Picks the canonical top-level folder when multiple non-deleted roots exist.
  /// Prefers the default Library title, then earliest [createdAt].
  static String? canonicalTopLevelRootId(List<Collection> all) {
    final tops = all
        .where(
          (c) =>
              !c.isDeleted &&
              (c.parentId == null || c.parentId!.trim().isEmpty),
        )
        .toList();
    if (tops.isEmpty) return null;
    tops.sort((a, b) {
      final aLib =
          a.title.trim() == LibraryRootCollection.defaultTitle ? 0 : 1;
      final bLib =
          b.title.trim() == LibraryRootCollection.defaultTitle ? 0 : 1;
      if (aLib != bLib) return aLib.compareTo(bLib);
      return a.createdAt.compareTo(b.createdAt);
    });
    return tops.first.id;
  }

  /// Copies [collection] with a new [parentId] (ObjectBox repair).
  static Collection withParentId(Collection collection, String newParentId) {
    return Collection(
      id: collection.id,
      ownerId: collection.ownerId,
      parentId: newParentId,
      isShared: collection.isShared,
      title: collection.title,
      description: collection.description,
      category: collection.category,
      colorHex: collection.colorHex,
      iconName: collection.iconName,
      iconJson: collection.iconJson,
      position: collection.position,
      isPinned: collection.isPinned,
      isArchived: collection.isArchived,
      isDeleted: collection.isDeleted,
      childCount: collection.childCount,
      createdAt: collection.createdAt,
      updatedAt: DateTime.now(),
      lastAccessedAt: collection.lastAccessedAt,
      itemsLayout: collection.itemsLayout,
      childCollectionsLayout: collection.childCollectionsLayout,
      itemsSortDefault: collection.itemsSortDefault,
      openLinksIn: collection.openLinksIn,
      showLinkPreviews: collection.showLinkPreviews,
      itemCount: collection.itemCount,
    );
  }

  /// When the server library root id [serverRootId] differs from the local root
  /// [localRootId], rewrites collection ids and `parent_id` references so the
  /// batch upsert targets a single root row on Supabase.
  ///
  /// **Deduplication:** If [collections] contains a row whose `id` is already
  /// [serverRootId] but is NOT [localRootId] (i.e. the server root was pulled
  /// from Supabase into ObjectBox by a prior delta-sync pull), that row is
  /// dropped before remapping. Without this filter the remapped local root
  /// (L→S) and the original pulled server root (S) would both appear in the
  /// payload with `parent_id = null`, triggering `assertValidRootRows`.
  static List<Collection> collectionsWithRemappedRootIds(
    List<Collection> collections, {
    required String localRootId,
    required String serverRootId,
  }) {
    if (localRootId == serverRootId) return collections;

    bool parentRefsLocal(String? parentId) {
      if (parentId == null) return false;
      return parentId.trim() == localRootId;
    }

    // Drop any collection that already carries the server root id but is not
    // the local root. This is the "ghost" server root inserted by a delta-sync
    // pull — the remapped local root covers it in the upsert payload.
    final deduped = collections
        .where((c) => !(c.id == serverRootId && c.id != localRootId))
        .toList();

    return deduped.map((c) {
      final newId = c.id == localRootId ? serverRootId : c.id;
      final newParent = parentRefsLocal(c.parentId) ? serverRootId : c.parentId;
      if (newId == c.id && newParent == c.parentId) return c;
      return Collection(
        id: newId,
        ownerId: c.ownerId,
        parentId: newParent,
        isShared: c.isShared,
        title: c.title,
        description: c.description,
        category: c.category,
        colorHex: c.colorHex,
        iconName: c.iconName,
        iconJson: c.iconJson,
        position: c.position,
        isPinned: c.isPinned,
        isArchived: c.isArchived,
        isDeleted: c.isDeleted,
        childCount: c.childCount,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        lastAccessedAt: c.lastAccessedAt,
        itemsLayout: c.itemsLayout,
        childCollectionsLayout: c.childCollectionsLayout,
        itemsSortDefault: c.itemsSortDefault,
        openLinksIn: c.openLinksIn,
        showLinkPreviews: c.showLinkPreviews,
        itemCount: c.itemCount,
      );
    }).toList();
  }

  /// Maps [collections] to Supabase JSON rows for [userId].
  static List<Map<String, dynamic>> toSupabaseCollectionJson(
    List<Collection> collections,
    String userId,
  ) {
    return collections
        .map((c) => SupabaseCollectionMapper.toJson(c, userId))
        .toList();
  }

  /// Rewrites [Item.collectionId] when it still references the local library root.
  static Item itemWithRemappedRootCollection(
    Item item, {
    required String? localRootId,
    required String? serverRootId,
  }) {
    if (localRootId == null ||
        serverRootId == null ||
        localRootId == serverRootId) {
      return item;
    }
    if (item.collectionId.trim() == localRootId) {
      return item.copyWith(collectionId: serverRootId);
    }
    return item;
  }

  /// Counts rows that would be stored as `parent_id IS NULL` and not deleted.
  static int countActiveRootRowsInJson(Iterable<Map<String, dynamic>> rows) {
    var n = 0;
    for (final m in rows) {
      final deleted = m['is_deleted'] as bool? ?? false;
      if (deleted) continue;
      final p = m['parent_id'];
      if (p == null) n++;
    }
    return n;
  }
}
