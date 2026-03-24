import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

bool _isOnlineFromResults(List<ConnectivityResult> results) {
  if (results.isEmpty) return true;
  return results.any((r) => r != ConnectivityResult.none);
}

/// Raw connectivity stream from the platform (debounced after first emit).
final connectivityResultsProvider =
    StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged.debounceTime(
    const Duration(milliseconds: 450),
  );
});

/// Sprint 5-6: drives repository selection (cloud vs local cache).
///
/// Treats empty/unknown results as online (optimistic) to avoid false offline.
final isOnlineProvider = Provider<bool>((ref) {
  final async = ref.watch(connectivityResultsProvider);
  return async.when(
    data: _isOnlineFromResults,
    loading: () => true,
    error: (_, __) => true,
  );
});
