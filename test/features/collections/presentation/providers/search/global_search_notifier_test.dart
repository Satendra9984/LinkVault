import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_state.dart';
import 'package:link_vault/features/items/domain/models/url_items_query.dart';
import 'package:link_vault/features/items/domain/url_sort_option.dart';
import 'package:link_vault/features/items/presentation/providers/items_list_models.dart';

/// Smoke: state transitions without hitting search history persistence.
void main() {
  test('GlobalSearchState linksFiltersActive detects non-default filters', () {
    expect(const GlobalSearchState().linksFiltersActive, isFalse);
    expect(
      const GlobalSearchState(linksSortOption: UrlSortOption.mostVisited)
          .linksFiltersActive,
      isTrue,
    );
    expect(
      const GlobalSearchState(linksViewMode: UrlViewMode.cards)
          .linksFiltersActive,
      isTrue,
    );
  });

  test('GlobalSearchState collectionsFiltersActive detects folder filters', () {
    expect(const GlobalSearchState().collectionsFiltersActive, isFalse);
    expect(
      const GlobalSearchState(collectionsIncludeArchived: true)
          .collectionsFiltersActive,
      isTrue,
    );
  });

  test('GlobalSearchState keeps draft and committed queries separate', () {
    const state = GlobalSearchState(
      collectionsSearchDraft: 'flutter',
      collectionsCommittedQuery: '',
      linksSearchDraft: 'riverpod',
      linksCommittedQuery: 'riverpod',
    );

    expect(state.collectionsSearchDraft, 'flutter');
    expect(state.collectionsCommittedQuery, isEmpty);
    expect(state.linksSearchDraft, 'riverpod');
    expect(state.linksCommittedQuery, 'riverpod');
  });

  test('GlobalSearchState default view modes are compact folders + icons URLs',
      () {
    expect(const GlobalSearchState().collectionsViewMode, UrlViewMode.icons);
    expect(const GlobalSearchState().linksViewMode, UrlViewMode.icons);
  });

  group('UrlItemsQuery null collectionId', () {
    test('null collectionId accepted (global cross-collection path)', () {
      const q = UrlItemsQuery(limit: 20, offset: 0);
      expect(q.collectionId, isNull);
      expect(q.limit, 20);
      expect(q.offset, 0);
    });

    test('non-null collectionId accepted (per-collection path)', () {
      const q = UrlItemsQuery(collectionId: 'abc', limit: 20, offset: 0);
      expect(q.collectionId, 'abc');
    });

    test('default filter values are safe for global query', () {
      const q = UrlItemsQuery(limit: 20, offset: 0);
      expect(q.searchQuery, '');
      expect(q.pinnedOnly, isFalse);
      expect(q.withDescriptionOnly, isFalse);
      expect(q.withImageOnly, isFalse);
      expect(q.domainContains, '');
      expect(q.savedAfter, isNull);
      expect(q.savedBefore, isNull);
      expect(q.status, isNull);
    });
  });
}
