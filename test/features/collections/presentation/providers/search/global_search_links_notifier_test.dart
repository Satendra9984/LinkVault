import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_links_notifier.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_query_providers.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_tier.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/items/domain/models/url_items_query.dart';
import 'package:link_vault/features/items/domain/repositories/i_items_repository.dart';
import 'package:link_vault/features/items/presentation/providers/items_providers.dart';

// ── Fake repository ────────────────────────────────────────────────────────

class _FakeItemsRepo implements IItemsRepository {
  _FakeItemsRepo({
    required List<Item> pageItems,
    this.hasMore = false,
    this.failure,
  }) : pageItems = List<Item>.of(pageItems);

  final List<Item> pageItems;
  bool hasMore;
  final Failure? failure;

  int callCount = 0;

  @override
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(UrlItemsQuery query) async {
    callCount++;
    if (failure != null) return Left(failure!);
    // Copy the list so future mutations to pageItems don't affect the returned page.
    return Right(UrlItemsPage(items: List<Item>.of(pageItems), hasMore: hasMore));
  }

  // ── Remaining IItemsRepository stubs ──────────────────────────────────────

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
    String collectionId,
    int limit,
    int offset,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, Item?>> getItem(String id) async => const Right(null);

  @override
  Future<Either<Failure, void>> createItem(Item item) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateItem(Item item) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteItem(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> toggleItemPin(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> toggleItemArchive(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> markItemReadAndTrack(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> reorderItems(
    String collectionId,
    List<String> orderedIds,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateItemPosition(
    String id,
    double newPosition,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, Item?>> findItemByCollectionAndNormalizedLink(
    String collectionId,
    String link,
  ) async =>
      const Right(null);
}

// ── Helper ─────────────────────────────────────────────────────────────────

Item _item(String id) => Item(
      id: id,
      collectionId: 'c1',
      title: 'Title $id',
      status: ItemStatus.unread,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );

/// Builds a [ProviderContainer] with the given [repo] overriding both
/// `itemsRepositoryProvider` and `localItemsRepositoryProvider`, and
/// hard-wiring `globalSearchItemsDataModeProvider` to [activeRepository].
ProviderContainer _makeContainer(_FakeItemsRepo repo) {
  return ProviderContainer(
    overrides: [
      itemsRepositoryProvider.overrideWithValue(repo),
      localItemsRepositoryProvider.overrideWithValue(repo),
      globalSearchItemsDataModeProvider
          .overrideWith((_) async => GlobalSearchItemsDataMode.activeRepository),
    ],
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('GlobalSearchLinksNotifier', () {
    test('initial state is idle with empty items', () {
      final container = _makeContainer(_FakeItemsRepo(pageItems: []));
      addTearDown(container.dispose);

      final state = container.read(globalSearchLinksNotifierProvider);
      expect(state.phase, GlobalSearchLinksPhase.idle);
      expect(state.items, isEmpty);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });

    test('searchAndReset transitions to loaded and populates items', () async {
      final items = [_item('a'), _item('b')];
      final container = _makeContainer(
        _FakeItemsRepo(pageItems: items, hasMore: false),
      );
      addTearDown(container.dispose);

      await container
          .read(globalSearchLinksNotifierProvider.notifier)
          .searchAndReset();

      final state = container.read(globalSearchLinksNotifierProvider);
      expect(state.phase, GlobalSearchLinksPhase.loaded);
      expect(state.items.map((i) => i.id), containsAll(['a', 'b']));
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });

    test('searchAndReset replaces previous results', () async {
      final repo = _FakeItemsRepo(pageItems: [_item('x')], hasMore: false);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(globalSearchLinksNotifierProvider.notifier);
      await notifier.searchAndReset();
      expect(container.read(globalSearchLinksNotifierProvider).items.length, 1);

      repo.pageItems
        ..clear()
        ..addAll([_item('y'), _item('z')]);
      await notifier.searchAndReset();

      final state = container.read(globalSearchLinksNotifierProvider);
      expect(state.items.length, 2);
      expect(state.items.map((i) => i.id), containsAll(['y', 'z']));
    });

    test('fetchNextPage appends next page when hasMore is true', () async {
      final firstPage = [_item('p1-a'), _item('p1-b')];
      final repo = _FakeItemsRepo(pageItems: firstPage, hasMore: true);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(globalSearchLinksNotifierProvider.notifier);

      // Load page 1.
      await notifier.searchAndReset();
      expect(container.read(globalSearchLinksNotifierProvider).items.length, 2);

      // Set up page 2 (last page).
      repo.pageItems
        ..clear()
        ..addAll([_item('p2-a')]);
      repo.hasMore = false;

      await notifier.fetchNextPage();

      final state = container.read(globalSearchLinksNotifierProvider);
      expect(state.items.length, 3);
      expect(state.items.map((i) => i.id), containsAll(['p1-a', 'p1-b', 'p2-a']));
      expect(state.hasMore, isFalse);
    });

    test('fetchNextPage is a no-op when hasMore is false', () async {
      final repo = _FakeItemsRepo(pageItems: [_item('a')], hasMore: false);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(globalSearchLinksNotifierProvider.notifier);
      await notifier.searchAndReset();
      final beforeCount = repo.callCount;

      await notifier.fetchNextPage();

      expect(repo.callCount, beforeCount, reason: 'no extra fetch when hasMore=false');
    });

    test('fetchNextPage is a no-op before first searchAndReset', () async {
      final repo = _FakeItemsRepo(pageItems: [], hasMore: false);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(globalSearchLinksNotifierProvider.notifier)
          .fetchNextPage();

      expect(repo.callCount, 0);
      expect(
        container.read(globalSearchLinksNotifierProvider).phase,
        GlobalSearchLinksPhase.idle,
      );
    });

    test('searchAndReset sets phase=error on repository failure', () async {
      const failure = ValidationFailure('DB error');
      final repo = _FakeItemsRepo(pageItems: [], failure: failure);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(globalSearchLinksNotifierProvider.notifier)
          .searchAndReset();

      final state = container.read(globalSearchLinksNotifierProvider);
      expect(state.phase, GlobalSearchLinksPhase.error);
      expect(state.errorMessage, contains('DB error'));
      expect(state.items, isEmpty);
    });

    test('reset returns to idle state', () async {
      final repo = _FakeItemsRepo(pageItems: [_item('a')], hasMore: false);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(globalSearchLinksNotifierProvider.notifier);
      await notifier.searchAndReset();
      expect(container.read(globalSearchLinksNotifierProvider).phase,
          GlobalSearchLinksPhase.loaded);

      notifier.reset();

      final state = container.read(globalSearchLinksNotifierProvider);
      expect(state.phase, GlobalSearchLinksPhase.idle);
      expect(state.items, isEmpty);
      expect(state.hasMore, isFalse);
    });
  });
}
