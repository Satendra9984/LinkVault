import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/infrastructure/providers.dart';
import '../../../../core/providers/network_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../application/cloud_delta_sync_service.dart';
import '../../data/sync_metadata_store.dart';
import '../../domain/cloud_sync_trigger.dart';
import '../../domain/delta_sync_error_kind.dart';
import 'sync_coordinator_config.dart';

final syncMetadataStoreProvider = Provider<SyncMetadataStore>((ref) {
  return SyncMetadataStore();
});

final cloudDeltaSyncServiceProvider = Provider<CloudDeltaSyncService>((ref) {
  final cfg = ref.watch(syncCoordinatorConfigProvider);
  return CloudDeltaSyncService(
    supabase: Supabase.instance.client,
    store: ref.watch(appDatabaseProvider).store,
    metadataStore: ref.watch(syncMetadataStoreProvider),
    maxAttempts: cfg.deltaSyncMaxAttempts,
    pushBatchSize: cfg.pushBatchSize,
  );
});

/// UI-facing cloud sync status + manual/auto triggers.
class SyncUiState {
  final bool isRunning;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final int pendingApprox;

  const SyncUiState({
    this.isRunning = false,
    this.lastSuccessAt,
    this.lastError,
    this.pendingApprox = 0,
  });

  SyncUiState copyWith({
    bool? isRunning,
    DateTime? lastSuccessAt,
    String? lastError,
    bool clearError = false,
    int? pendingApprox,
  }) {
    return SyncUiState(
      isRunning: isRunning ?? this.isRunning,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
      pendingApprox: pendingApprox ?? this.pendingApprox,
    );
  }
}

final syncCoordinatorProvider =
    NotifierProvider<SyncCoordinator, SyncUiState>(SyncCoordinator.new);

class SyncCoordinator extends Notifier<SyncUiState> {
  DateTime? _lastAutoSync;

  @override
  SyncUiState build() {
    ref.listen(isOnlineProvider, (prev, next) {
      if (next == true && prev == false) {
        runSync(manual: false, trigger: CloudSyncTrigger.reconnect);
      }
    });
    ref.listen(currentUserProvider, (_, __) {
      _refreshPendingOnly();
    });
    ref.listen(hasMigratedToCloudProvider, (_, __) {
      _refreshPendingOnly();
    });
    Future.microtask(_refreshPendingOnly);
    return const SyncUiState();
  }

  void onAppResumed() =>
      runSync(manual: false, trigger: CloudSyncTrigger.resume);

  void _refreshPendingOnly() {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isGuest || user.supabaseId == null) {
      state = state.copyWith(pendingApprox: 0);
      return;
    }
    if (!ref.read(hasMigratedToCloudProvider)) {
      state = state.copyWith(pendingApprox: 0);
      return;
    }
    final store = ref.read(appDatabaseProvider).store;
    final meta = ref.read(syncMetadataStoreProvider);
    meta.getLastSyncedAt(user.supabaseId!).then((anchor) {
      final n = CloudDeltaSyncService.countPendingForUser(
        store,
        user.supabaseId!,
        anchor,
      );
      state = state.copyWith(pendingApprox: n);
    });
  }

  /// Runs delta pull/push when signed-in, migrated, and online.
  ///
  /// [trigger] is used when [manual] is false (reconnect / resume / bootstrap).
  Future<void> runSync({
    required bool manual,
    CloudSyncTrigger trigger = CloudSyncTrigger.bootstrap,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isGuest || user.supabaseId == null) return;
    if (!ref.read(hasMigratedToCloudProvider)) {
      if (manual) {
        state = state.copyWith(
          lastError: 'Complete cloud migration first.',
        );
      }
      return;
    }
    if (!ref.read(isOnlineProvider)) {
      if (manual) {
        state = state.copyWith(lastError: 'You are offline.');
      }
      return;
    }

    final cfg = ref.read(syncCoordinatorConfigProvider);
    final now = DateTime.now();
    if (!manual &&
        _lastAutoSync != null &&
        now.difference(_lastAutoSync!) < cfg.autoSyncMinInterval) {
      return;
    }

    final syncTrigger =
        manual ? CloudSyncTrigger.manual : trigger;

    state = state.copyWith(isRunning: true, clearError: true);
    final service = ref.read(cloudDeltaSyncServiceProvider);
    final result = await service.run(
      userId: user.supabaseId!,
      syncTrigger: syncTrigger,
    );

    if (result.ok) {
      _lastAutoSync = now;
      AppLogger.i(
        '[SyncCoordinator] ok trigger=${syncTrigger.name} user=${user.supabaseId} '
        'pending~=${result.pendingLocalApprox}',
      );
      state = state.copyWith(
        isRunning: false,
        lastSuccessAt: DateTime.now(),
        pendingApprox: result.pendingLocalApprox,
        clearError: true,
      );
    } else {
      final kind = result.failureKind ?? DeltaSyncErrorKind.unknown;
      final msg = userFacingDeltaSyncMessage(kind, result.errorMessage);
      AppLogger.w(
        '[SyncCoordinator] fail trigger=${syncTrigger.name} kind=$kind msg=$msg',
      );
      state = state.copyWith(
        isRunning: false,
        lastError: msg,
        pendingApprox: result.pendingLocalApprox,
      );
    }
  }
}
