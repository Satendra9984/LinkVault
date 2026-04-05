import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/collections/domain/library_root_collection.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/monetization/application/cloud_migration_root_alignment.dart';

Collection _col({
  required String id,
  String? parentId,
  required String title,
  DateTime? createdAt,
  bool isDeleted = false,
}) {
  final now = createdAt ?? DateTime.utc(2025, 1, 1);
  return Collection(
    id: id,
    parentId: parentId,
    title: title,
    category: 'general',
    colorHex: '#000000',
    iconName: '📁',
    position: 0,
    createdAt: now,
    updatedAt: now,
    isDeleted: isDeleted,
  );
}

void main() {
  group('CloudMigrationRootAlignment.canonicalTopLevelRootId', () {
    test('prefers Library title over other top-level folders', () {
      final lib = _col(
        id: 'lib-id',
        parentId: null,
        title: LibraryRootCollection.defaultTitle,
        createdAt: DateTime.utc(2025, 6, 1),
      );
      final other = _col(
        id: 'other-id',
        parentId: null,
        title: 'Work',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      final id = CloudMigrationRootAlignment.canonicalTopLevelRootId([
        other,
        lib,
      ]);
      expect(id, 'lib-id');
    });

    test('falls back to earliest createdAt when no Library title', () {
      final a = _col(
        id: 'a',
        parentId: null,
        title: 'A',
        createdAt: DateTime.utc(2025, 2, 1),
      );
      final b = _col(
        id: 'b',
        parentId: null,
        title: 'B',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      expect(
        CloudMigrationRootAlignment.canonicalTopLevelRootId([a, b]),
        'b',
      );
    });

    test('ignores deleted top-level rows', () {
      final active = _col(
        id: 'active',
        parentId: null,
        title: 'X',
      );
      final deleted = _col(
        id: 'gone',
        parentId: null,
        title: 'Y',
        isDeleted: true,
      );
      expect(
        CloudMigrationRootAlignment.canonicalTopLevelRootId([active, deleted]),
        'active',
      );
    });
  });

  group('CloudMigrationRootAlignment.collectionsWithRemappedRootIds', () {
    const localRoot = 'local-uuid';
    const serverRoot = 'server-uuid';
    const userId = 'user-uuid';

    test('rewrites local root id to server id and reparents children', () {
      final root = _col(id: localRoot, parentId: null, title: 'Library');
      final child = _col(
        id: 'child',
        parentId: localRoot,
        title: 'Guest folder',
      );
      final remapped =
          CloudMigrationRootAlignment.collectionsWithRemappedRootIds(
        [root, child],
        localRootId: localRoot,
        serverRootId: serverRoot,
      );
      expect(remapped[0].id, serverRoot);
      expect(remapped[0].parentId, isNull);
      expect(remapped[1].id, 'child');
      expect(remapped[1].parentId, serverRoot);

      final json =
          CloudMigrationRootAlignment.toSupabaseCollectionJson(remapped, userId);
      expect(CloudMigrationRootAlignment.countActiveRootRowsInJson(json), 1);
      final rootRow = json.firstWhere((m) => m['id'] == serverRoot);
      expect(rootRow['parent_id'], isNull);
      final childRow = json.firstWhere((m) => m['id'] == 'child');
      expect(childRow['parent_id'], serverRoot);
    });

    test('is no-op when local and server root ids match', () {
      final root = _col(id: localRoot, parentId: null, title: 'Library');
      final input = [root];
      final remapped =
          CloudMigrationRootAlignment.collectionsWithRemappedRootIds(
        input,
        localRootId: localRoot,
        serverRootId: localRoot,
      );
      expect(identical(remapped, input), isTrue);
      expect(remapped.single.id, localRoot);
    });

    // Bug 2 regression: first delta-sync pull inserts server root S into
    // ObjectBox. Push phase then has [L, S, children] where both L and S have
    // parentId=null. Without dedup the remap produces two rows with id=S and
    // parent_id=null → assertValidRootRows fires.
    test(
        'deduplicates pulled server root S when local root L is also present',
        () {
      final localRootCollection =
          _col(id: localRoot, parentId: null, title: 'Library');
      final serverRootCollection = _col(
        id: serverRoot,
        parentId: null,
        title: 'Library',
        createdAt: DateTime.utc(2025, 6, 1), // pulled from server, newer
      );
      final child = _col(
        id: 'child-1',
        parentId: serverRoot, // child was updated by prior sync to point at S
        title: 'Work',
      );

      // Input mirrors ObjectBox state after migration + first pull:
      // L (local ghost, parentId=null) + S (pulled server root, parentId=null)
      // + child (parentId=S from pull).
      final remapped =
          CloudMigrationRootAlignment.collectionsWithRemappedRootIds(
        [localRootCollection, serverRootCollection, child],
        localRootId: localRoot,
        serverRootId: serverRoot,
      );

      // S (from localRootCollection remapped) must appear exactly once.
      final rootRows = remapped.where((c) => c.id == serverRoot).toList();
      expect(rootRows, hasLength(1));
      expect(rootRows.single.parentId, isNull);

      // Child should be present unchanged.
      final childRows = remapped.where((c) => c.id == 'child-1').toList();
      expect(childRows, hasLength(1));

      // JSON payload must have exactly 1 active root.
      final json =
          CloudMigrationRootAlignment.toSupabaseCollectionJson(remapped, userId);
      expect(CloudMigrationRootAlignment.countActiveRootRowsInJson(json), 1);
    });
  });

  group('CloudMigrationRootAlignment.itemWithRemappedRootCollection', () {
    test('maps collection_id from local root to server root', () {
      final now = DateTime.utc(2025, 1, 1);
      final item = Item(
        id: 'item-1',
        collectionId: 'local-root',
        title: 't',
        status: ItemStatus.unread,
        createdAt: now,
        updatedAt: now,
      );
      final out = CloudMigrationRootAlignment.itemWithRemappedRootCollection(
        item,
        localRootId: 'local-root',
        serverRootId: 'server-root',
      );
      expect(out.collectionId, 'server-root');
    });

    test('leaves items in nested folders unchanged', () {
      final now = DateTime.utc(2025, 1, 1);
      final item = Item(
        id: 'item-1',
        collectionId: 'nested-id',
        title: 't',
        status: ItemStatus.unread,
        createdAt: now,
        updatedAt: now,
      );
      final out = CloudMigrationRootAlignment.itemWithRemappedRootCollection(
        item,
        localRootId: 'local-root',
        serverRootId: 'server-root',
      );
      expect(out.collectionId, 'nested-id');
    });
  });

  group('CloudMigrationRootAlignment.countActiveRootRowsInJson', () {
    test('counts only non-deleted rows with null parent_id', () {
      final rows = [
        {'parent_id': null, 'is_deleted': false},
        {'parent_id': 'x', 'is_deleted': false},
        {'parent_id': null, 'is_deleted': true},
      ];
      expect(CloudMigrationRootAlignment.countActiveRootRowsInJson(rows), 1);
    });
  });
}
