import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/infrastructure/providers.dart';
import '../../../data/models/search_history_model.dart';
import '../../../data/repositories/search_history_repository.dart';
import 'search_state.dart';

// ── Repository provider ────────────────────────────────────────────────────

final searchHistoryRepositoryProvider =
    Provider<SearchHistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SearchHistoryRepository(db.store);
});

// ── History stream ─────────────────────────────────────────────────────────

/// Reactive stream of the 10 most recent search queries, newest first.
final searchHistoryProvider =
    StreamProvider<List<SearchHistoryModel>>((ref) {
  return ref.watch(searchHistoryRepositoryProvider).watchHistory();
});

// ── Search Notifier ────────────────────────────────────────────────────────

class SearchNotifier extends AutoDisposeNotifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateSortOption(String sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void togglePrivateFilter(bool showOnlyPrivate) {
    state = state.copyWith(showOnlyPrivate: showOnlyPrivate);
  }

  /// Saves the current query to history and triggers a search.
  Future<void> submitQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    updateQuery(trimmed);
    await ref
        .read(searchHistoryRepositoryProvider)
        .addQuery(trimmed);
  }

  Future<void> removeHistoryEntry(int id) async {
    await ref.read(searchHistoryRepositoryProvider).removeQuery(id);
  }

  Future<void> clearHistory() async {
    await ref.read(searchHistoryRepositoryProvider).clearAll();
  }
}

final searchNotifierProvider =
    NotifierProvider.autoDispose<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
