import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../items/domain/entities/item.dart';
import '../../../../items/domain/models/url_items_query.dart';
import '../../../../items/presentation/providers/items_providers.dart';
import 'global_search_notifier.dart';
import 'global_search_query_providers.dart';
import 'global_search_tier.dart';

/// Phase of a paginated global links search.
enum GlobalSearchLinksPhase { idle, loading, loaded, error }

/// Immutable state for [GlobalSearchLinksNotifier].
class GlobalSearchLinksState {
  const GlobalSearchLinksState({
    this.items = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.phase = GlobalSearchLinksPhase.idle,
    this.errorMessage,
  });

  final List<Item> items;
  final bool hasMore;
  final bool isLoadingMore;
  final GlobalSearchLinksPhase phase;
  final String? errorMessage;

  GlobalSearchLinksState copyWith({
    List<Item>? items,
    bool? hasMore,
    bool? isLoadingMore,
    GlobalSearchLinksPhase? phase,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GlobalSearchLinksState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Paginated global links search notifier.
///
/// Call [searchAndReset] when the user commits a new query (page 0, replaces
/// results). Call [fetchNextPage] from the scroll listener to append pages.
/// Page size is 20, matching [ItemsNotifier._pageSize].
class GlobalSearchLinksNotifier
    extends Notifier<GlobalSearchLinksState> {
  static const _pageSize = 20;

  @override
  GlobalSearchLinksState build() => const GlobalSearchLinksState();

  /// Runs a fresh page-0 search with the current committed filters from
  /// [globalSearchNotifierProvider]. Replaces any existing results.
  Future<void> searchAndReset() async {
    state = const GlobalSearchLinksState(phase: GlobalSearchLinksPhase.loading);
    await _fetch(offset: 0, append: false);
  }

  /// Appends the next page of results. No-op when already at end or loading.
  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetch(offset: state.items.length, append: true);
  }

  /// Resets state to idle (called when search is cleared).
  void reset() {
    state = const GlobalSearchLinksState();
  }

  Future<void> _fetch({required int offset, required bool append}) async {
    final gs = ref.read(globalSearchNotifierProvider);
    final mode = await ref.read(globalSearchItemsDataModeProvider.future);
    final repo = mode == GlobalSearchItemsDataMode.localRepositoryOnly
        ? ref.read(localItemsRepositoryProvider)
        : ref.read(itemsRepositoryProvider);

    final q = UrlItemsQuery(
      // collectionId: null → cross-collection global query
      limit: _pageSize,
      offset: offset,
      searchQuery: gs.linksCommittedQuery,
      status: gs.linksStatusFilter,
      sort: gs.linksSortOption,
      pinnedOnly: gs.linksPinnedOnly,
      withDescriptionOnly: gs.linksWithDescriptionOnly,
      withImageOnly: gs.linksWithImageOnly,
      domainContains: gs.linksDomainQuery,
      savedAfter: gs.linksSavedAfter,
      savedBefore: gs.linksSavedBefore,
    );

    final result = await repo.queryUrlItems(q);
    result.fold(
      (failure) {
        state = GlobalSearchLinksState(
          items: append ? state.items : const [],
          phase: GlobalSearchLinksPhase.error,
          errorMessage: failure.message,
          isLoadingMore: false,
        );
      },
      (page) {
        final newItems =
            append ? [...state.items, ...page.items] : page.items;
        state = GlobalSearchLinksState(
          items: newItems,
          hasMore: page.hasMore,
          isLoadingMore: false,
          phase: GlobalSearchLinksPhase.loaded,
        );
      },
    );
  }
}

final globalSearchLinksNotifierProvider =
    NotifierProvider<GlobalSearchLinksNotifier, GlobalSearchLinksState>(
  GlobalSearchLinksNotifier.new,
);
