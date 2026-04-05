import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_filtering.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_state.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/items/domain/url_sort_option.dart';

// Helper to reduce boilerplate in tests.
Collection _col({
  required String id,
  required String title,
  String? parentId = 'library-root',
  String category = 'Dev',
  bool isDeleted = false,
  bool isArchived = false,
  bool isShared = false,
  DateTime? updatedAt,
  DateTime? createdAt,
}) {
  final now = updatedAt ?? DateTime(2025, 6, 1);
  return Collection(
    id: id,
    parentId: parentId,
    title: title,
    category: category,
    colorHex: '#000',
    iconName: 'folder',
    position: 0,
    isDeleted: isDeleted,
    isArchived: isArchived,
    isShared: isShared,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

void main() {
  group('filterAndSortCollectionsForGlobalSearch', () {
    test('filters by title and excludes deleted', () {
      final all = [
        _col(id: '1', title: 'Flutter tips', isDeleted: true),
        _col(id: '2', title: 'Flutter apps'),
      ];
      const state = GlobalSearchState(
        collectionsCommittedQuery: 'flutter',
      );
      final out = filterAndSortCollectionsForGlobalSearch(all, state);
      expect(out.length, 1);
      expect(out.single.id, '2');
    });

    test('ignores collections draft until committed', () {
      final all = [
        _col(id: '1', title: 'Flutter tips'),
        _col(id: '2', title: 'Supabase notes'),
      ];
      const state = GlobalSearchState(
        collectionsSearchDraft: 'flutter',
        collectionsCommittedQuery: '',
      );
      final out = filterAndSortCollectionsForGlobalSearch(all, state);
      // Both non-deleted, non-root, no committed query → both shown.
      expect(out.length, 2);
    });

    test('excludes collections with null parentId (root/library root)', () {
      final rootCollection = _col(id: 'root', title: 'Library', parentId: null);
      final nested = _col(id: 'child', title: 'Work', parentId: 'root');
      final out = filterAndSortCollectionsForGlobalSearch(
        [rootCollection, nested],
        const GlobalSearchState(),
      );
      expect(out.map((c) => c.id), isNot(contains('root')));
      expect(out.map((c) => c.id), contains('child'));
    });

    test('excludes collections with empty string parentId', () {
      final root = _col(id: 'lib', title: 'Lib', parentId: '');
      final out = filterAndSortCollectionsForGlobalSearch(
        [root],
        const GlobalSearchState(),
      );
      expect(out, isEmpty);
    });

    test('includes collections with a non-empty parentId', () {
      final nested = _col(id: 'n1', title: 'Notes', parentId: 'parent-1');
      final out = filterAndSortCollectionsForGlobalSearch(
        [nested],
        const GlobalSearchState(),
      );
      expect(out.length, 1);
      expect(out.single.id, 'n1');
    });

    test('sorts titleAsc by default', () {
      final all = [
        _col(id: 'b', title: 'Banana'),
        _col(id: 'a', title: 'Apple'),
      ];
      final out = filterAndSortCollectionsForGlobalSearch(
        all,
        const GlobalSearchState(),
      );
      expect(out.map((c) => c.id).toList(), ['a', 'b']);
    });
  });

  group('filterAndSortLinksForGlobalSearch', () {
    test('uses committed query and status filter', () {
      final now = DateTime(2025, 6, 1);
      final items = [
        Item(
          id: 'a',
          collectionId: 'c1',
          title: 'Hello',
          link: 'https://example.com',
          status: ItemStatus.unread,
          createdAt: now,
          updatedAt: now,
        ),
        Item(
          id: 'b',
          collectionId: 'c1',
          title: 'Other',
          link: 'https://foo.com',
          status: ItemStatus.read,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final state = GlobalSearchState(
        linksCommittedQuery: 'example',
        linksStatusFilter: ItemStatus.unread,
      );
      final out = filterAndSortLinksForGlobalSearch(items, state);
      expect(out.length, 1);
      expect(out.single.id, 'a');
    });

    test('sorts by title when alphabeticalAsc', () {
      final now = DateTime(2025, 6, 1);
      final items = [
        Item(
          id: 'z',
          collectionId: 'c',
          title: 'Zebra',
          status: ItemStatus.read,
          createdAt: now,
          updatedAt: now,
        ),
        Item(
          id: 'a',
          collectionId: 'c',
          title: 'Alpha',
          status: ItemStatus.read,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      const state = GlobalSearchState(
        linksCommittedQuery: '',
        linksSortOption: UrlSortOption.alphabeticalAsc,
      );
      final out = filterAndSortLinksForGlobalSearch(items, state);
      expect(out.map((e) => e.id).toList(), ['a', 'z']);
    });
  });
}
