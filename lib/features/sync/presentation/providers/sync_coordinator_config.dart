import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tunable sync behavior (tests can override via provider scope).
class SyncCoordinatorConfig {
  const SyncCoordinatorConfig({
    this.autoSyncMinInterval = const Duration(seconds: 10),
    this.deltaSyncMaxAttempts = 3,
    this.pushBatchSize = 50,
  });

  /// Minimum gap between automatic syncs (reconnect / resume / bootstrap).
  final Duration autoSyncMinInterval;

  /// Retries for transient failures inside `CloudDeltaSyncService.run`.
  final int deltaSyncMaxAttempts;

  /// Rows per `upsert` batch when pushing local changes to Supabase.
  final int pushBatchSize;
}

final syncCoordinatorConfigProvider = Provider<SyncCoordinatorConfig>((ref) {
  return const SyncCoordinatorConfig();
});
