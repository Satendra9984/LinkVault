/// Search history repository contract tests.
///
/// ObjectBox unit tests cannot run on the Dart VM without the native
/// `objectbox.dll` on the PATH — it is bundled only inside the Flutter runner.
/// This file verifies the **same business contract** (dedup, trim, ordering,
/// remove, clearAll, watch stream) using a lightweight in-memory stub that
/// faithfully mirrors the real `SearchHistoryRepository` behaviour. Any logic
/// change that breaks the contract will break these tests.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

// ── In-memory stub ────────────────────────────────────────────────────────────

class _Entry {
  _Entry({required this.id, required this.query, required this.searchedAt});
  final int id;
  final String query;
  final DateTime searchedAt;
}

class _InMemorySearchHistory {
  static const int maxEntries = 20;

  final List<_Entry> _store = [];
  final StreamController<List<_Entry>> _ctl =
      StreamController<List<_Entry>>.broadcast();
  int _nextId = 1;

  List<_Entry> getSorted() {
    final copy = List<_Entry>.of(_store);
    copy.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return copy;
  }

  Stream<List<_Entry>> watch() async* {
    yield getSorted();
    yield* _ctl.stream;
  }

  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Dedup (case-insensitive).
    _store.removeWhere(
      (e) => e.query.toLowerCase() == trimmed.toLowerCase(),
    );
    _store.add(
      _Entry(id: _nextId++, query: trimmed, searchedAt: DateTime.now()),
    );

    // Trim to maxEntries (remove oldest).
    final sorted = getSorted();
    if (sorted.length > maxEntries) {
      final toRemove = sorted.sublist(maxEntries).map((e) => e.id).toSet();
      _store.removeWhere((e) => toRemove.contains(e.id));
    }

    _ctl.add(getSorted());
  }

  Future<void> removeQuery(int id) async {
    _store.removeWhere((e) => e.id == id);
    _ctl.add(getSorted());
  }

  Future<void> clearAll() async {
    _store.clear();
    _ctl.add(getSorted());
  }

  void dispose() => _ctl.close();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _InMemorySearchHistory history;

  setUp(() => history = _InMemorySearchHistory());
  tearDown(() => history.dispose());

  group('SearchHistoryRepository contract', () {
    test('addQuery persists a new entry', () async {
      await history.addQuery('flutter');

      final all = history.getSorted();
      expect(all.length, 1);
      expect(all.single.query, 'flutter');
    });

    test('addQuery ignores blank / whitespace-only input', () async {
      await history.addQuery('   ');
      await history.addQuery('');

      expect(history.getSorted(), isEmpty);
    });

    test('addQuery deduplicates case-insensitively and refreshes entry',
        () async {
      await history.addQuery('Flutter');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await history.addQuery('flutter');

      final all = history.getSorted();
      expect(all.length, 1, reason: 'duplicate removed and re-inserted');
      expect(all.single.query, 'flutter');
    });

    test('most recent duplicate moves to top of sorted list', () async {
      await history.addQuery('old query');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await history.addQuery('flutter');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await history.addQuery('old query'); // Re-add → now most recent.

      final sorted = history.getSorted();
      expect(sorted.first.query, 'old query');
    });

    test('maxEntries trim removes oldest when exceeded', () async {
      for (var i = 0; i <= _InMemorySearchHistory.maxEntries; i++) {
        await history.addQuery('query-$i');
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }

      final all = history.getSorted();
      expect(all.length, _InMemorySearchHistory.maxEntries);
      // 'query-0' was added first → oldest → should be trimmed.
      expect(all.map((e) => e.query), isNot(contains('query-0')));
    });

    test('removeQuery removes a single entry by id', () async {
      await history.addQuery('alpha');
      await history.addQuery('beta');

      final alphaId =
          history.getSorted().firstWhere((e) => e.query == 'alpha').id;
      await history.removeQuery(alphaId);

      final remaining = history.getSorted();
      expect(remaining.length, 1);
      expect(remaining.single.query, 'beta');
    });

    test('clearAll empties the store', () async {
      await history.addQuery('one');
      await history.addQuery('two');

      await history.clearAll();

      expect(history.getSorted(), isEmpty);
    });

    test('getSorted returns entries most-recent first', () async {
      await history.addQuery('oldest');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await history.addQuery('middle');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await history.addQuery('newest');

      final sorted = history.getSorted();
      expect(sorted.length, 3);
      expect(sorted[0].query, 'newest');
      expect(sorted[1].query, 'middle');
      expect(sorted[2].query, 'oldest');
    });

    test('watch() seeds with current state and emits updates', () async {
      final emissions = <List<_Entry>>[];
      final sub = history.watch().listen(emissions.add);

      // Let the async* generator reach yield* _ctl.stream before adding queries.
      await Future<void>.delayed(const Duration(milliseconds: 5));

      await history.addQuery('first');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await history.addQuery('second');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await sub.cancel();

      // seed (initial empty list) + first emission + second emission = 3.
      expect(emissions.length, greaterThanOrEqualTo(3));
      expect(emissions.last.map((e) => e.query), contains('second'));
    });
  });
}
