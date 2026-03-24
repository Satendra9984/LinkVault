import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../application/cloud_downgrade_service.dart';

/// Provides a configured [CloudDowngradeService] instance.
final cloudDowngradeServiceProvider = Provider<CloudDowngradeService>((ref) {
  return CloudDowngradeService(
    supabase: Supabase.instance.client,
    appDatabase: ref.watch(appDatabaseProvider),
  );
});

// ── Downgrade State ─────────────────────────────────────────────────────────

enum DowngradeAction { none, importing, deleting }

class DowngradeState {
  final DowngradeAction action;
  final double progress;
  final String message;
  final String? error;
  final bool isComplete;

  const DowngradeState({
    this.action = DowngradeAction.none,
    this.progress = 0.0,
    this.message = '',
    this.error,
    this.isComplete = false,
  });

  DowngradeState copyWith({
    DowngradeAction? action,
    double? progress,
    String? message,
    String? error,
    bool? isComplete,
  }) =>
      DowngradeState(
        action: action ?? this.action,
        progress: progress ?? this.progress,
        message: message ?? this.message,
        error: error,
        isComplete: isComplete ?? this.isComplete,
      );
}

/// Notifier controlling the cloud downgrade (import / delete) flow.
class CloudDowngradeNotifier extends Notifier<DowngradeState> {
  @override
  DowngradeState build() => const DowngradeState();

  Future<void> importFromCloud() async {
    state = const DowngradeState(
        action: DowngradeAction.importing, message: 'Starting import...');

    final service = ref.read(cloudDowngradeServiceProvider);
    final result = await service.importFromCloud(
      onProgress: (p, msg) => state = state.copyWith(progress: p, message: msg),
    );

    result.fold(
      (failure) => state = state.copyWith(
          action: DowngradeAction.none, error: failure.message),
      (_) => state = state.copyWith(isComplete: true, progress: 1.0,
          message: 'Import complete! You are now in local mode.'),
    );
  }

  Future<void> deleteRemoteData() async {
    state = const DowngradeState(
        action: DowngradeAction.deleting, message: 'Deleting remote data...');

    final service = ref.read(cloudDowngradeServiceProvider);
    final result = await service.deleteRemoteData(
      onProgress: (p, msg) => state = state.copyWith(progress: p, message: msg),
    );

    result.fold(
      (failure) => state = state.copyWith(
          action: DowngradeAction.none, error: failure.message),
      (_) => state = state.copyWith(isComplete: true, progress: 1.0,
          message: 'Remote data deleted. You are now in local mode.'),
    );
  }

  void reset() => state = const DowngradeState();
}

final cloudDowngradeNotifierProvider =
    NotifierProvider<CloudDowngradeNotifier, DowngradeState>(
        CloudDowngradeNotifier.new);
