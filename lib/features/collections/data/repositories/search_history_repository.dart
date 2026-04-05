import '../../../../objectbox.g.dart';
import '../models/search_history_model.dart';

/// Manages persistent search history using ObjectBox.
///
/// - Stores up to [maxEntries] unique queries (oldest removed when limit exceeded).
/// - Duplicate queries are deduped — the existing entry is updated with a new timestamp.
class SearchHistoryRepository {
  final Box<SearchHistoryModel> _box;

  static const int maxEntries = 20;

  SearchHistoryRepository(Store store)
      : _box = store.box<SearchHistoryModel>();

  // ── Watch ─────────────────────────────────────────────────────────────────

  /// Emits the history list sorted by most recent first, reactively.
  Stream<List<SearchHistoryModel>> watchHistory() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((_) => _getSorted());
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Saves [query] to history. Deduplicates and trims to [maxEntries].
  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Remove existing duplicate (case-insensitive).
    final existing = _box
        .query(SearchHistoryModel_.query.equals(trimmed, caseSensitive: false))
        .build()
        .find();
    if (existing.isNotEmpty) {
      _box.removeMany(existing.map((e) => e.id).toList());
    }

    // Insert new entry with current timestamp.
    _box.put(SearchHistoryModel(query: trimmed, searchedAt: DateTime.now()));

    // Trim to maxEntries (remove oldest).
    final all = _getSorted();
    if (all.length > maxEntries) {
      final toRemove = all.sublist(maxEntries).map((e) => e.id).toList();
      _box.removeMany(toRemove);
    }
  }

  /// Removes a single history entry by [id].
  Future<void> removeQuery(int id) async {
    _box.remove(id);
  }

  /// Clears all search history.
  Future<void> clearAll() async {
    _box.removeAll();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  List<SearchHistoryModel> _getSorted() {
    return _box.getAll()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
  }
}
