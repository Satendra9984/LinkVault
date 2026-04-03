import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/services/admob_service.dart';
import '../../domain/usecases/check_ad_access_usecase.dart';
import '../../domain/usecases/watch_ad_for_access_usecase.dart';

// ── Re-export for convenience ─────────────────────────────────────────────────
export '../../domain/usecases/check_ad_access_usecase.dart' show DayPassStatus;

/// After the 3-day window, persist consumption for signed-in users (server + local).
Future<void> syncInstallTrialConsumedIfPastWindow(Ref ref) async {
  final user = ref.read(currentUserProvider);
  if (user?.supabaseId == null) return;
  final settings = ref.read(appSettingsRepositoryProvider);
  if (await settings.isGuestMode()) return;
  if (await settings.getInstallTrialConsumedRemote()) return;
  final install = await settings.getInstallDate();
  if (install == null) return;
  final days = DateTime.now().difference(install).inHours / 24;
  if (days < 3) return;

  final result = await ref.read(profileRepositoryProvider).updateInstallTrialConsumed(
        userId: user!.supabaseId!,
        consumed: true,
      );

  await result.match(
    (f) async {
      AppLogger.w('AdGate: install trial server sync failed: ${f.message}');
    },
    (profile) async {
      await settings.setInstallTrialConsumedRemote(value: profile.installTrialConsumed);
      AppLogger.d('AdGate: install trial marked consumed on server');
    },
  );
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Resolves the current [DayPassStatus]. Used in GoRouter redirect and
/// soft-gate widgets. Kept separate from [dayPassProvider] so the gate
/// logic is decoupled from the full DayPass management screen state.
final adGateProvider = AsyncNotifierProvider<AdGateNotifier, DayPassStatus>(
    () => AdGateNotifier());

/// Lightweight [FutureProvider] for use inside the GoRouter redirect callback.
final adGateStatusProvider = FutureProvider<DayPassStatus>((ref) async {
  final isPremium = ref.read(isPremiumProvider);
  final repo = ref.read(daypassRepositoryProvider);
  await repo.cachePremiumStatus(isPremium: isPremium);
  await syncInstallTrialConsumedIfPastWindow(ref);
  return CheckAdAccessUseCase(repo).call();
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class AdGateNotifier extends AsyncNotifier<DayPassStatus> {
  @override
  Future<DayPassStatus> build() async {
    // Sync premium cache whenever auth changes.
    final isPremium = ref.watch(isPremiumProvider);
    final repo = ref.read(daypassRepositoryProvider);
    await repo.cachePremiumStatus(isPremium: isPremium);
    await syncInstallTrialConsumedIfPastWindow(ref);
    return CheckAdAccessUseCase(repo).call();
  }

  // ── Watch Ad ──────────────────────────────────────────────────────────────

  /// Delegates to [WatchAdForAccessUseCase] — no direct data-layer calls here.
  /// Returns `true` if the user earned the reward.
  Future<bool> watchAdForAccess() async {
    state = const AsyncLoading();
    try {
      final result = await WatchAdForAccessUseCase(
        ref.read(daypassRepositoryProvider),
        ref.read(admobServiceProvider),
      ).call();

      switch (result) {
        case WatchAdResult.earned:
          AppLogger.i('AdGate: reward earned — DayPass granted');
        case WatchAdResult.skipped:
          AppLogger.d('AdGate: ad skipped by user');
        case WatchAdResult.loadFailed:
          AppLogger.w('AdGate: ad failed to load — grace period active');
        case WatchAdResult.showFailed:
          AppLogger.w('AdGate: ad failed to show — grace period active');
        case WatchAdResult.notReady:
          AppLogger.w('AdGate: SDK not ready');
        case WatchAdResult.alreadyInProgress:
          AppLogger.w('AdGate: another ad already in progress');
      }

      await syncInstallTrialConsumedIfPastWindow(ref);
      final newStatus =
          await CheckAdAccessUseCase(ref.read(daypassRepositoryProvider))
              .call();
      state = AsyncData(newStatus);
      return result == WatchAdResult.earned;
    } catch (e, st) {
      AppLogger.e('AdGate: error during ad flow', e, st);
      state = const AsyncData(DayPassStatus.grace);
      return false;
    }
  }

  /// Re-evaluates access status (e.g. after returning from paywall).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(daypassRepositoryProvider);
      await syncInstallTrialConsumedIfPastWindow(ref);
      return CheckAdAccessUseCase(repo).call();
    });
  }

  /// Remaining time for install trial, DayPass stack, or legacy ad window.
  Future<Duration> remainingDuration() async {
    final repo = ref.read(daypassRepositoryProvider);
    await syncInstallTrialConsumedIfPastWindow(ref);
    final status = await CheckAdAccessUseCase(repo).call();
    if (status == DayPassStatus.freeTrial) {
      return repo.getFreeTrialRemainingDuration();
    }
    return repo.getDayPassRemainingDuration();
  }
}
