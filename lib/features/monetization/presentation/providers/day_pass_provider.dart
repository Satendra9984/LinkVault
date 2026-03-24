import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/services/admob_service.dart';
import '../../domain/usecases/check_ad_access_usecase.dart';
import '../../domain/usecases/watch_ad_for_access_usecase.dart';

// ── Re-export so screens only need to import this file ────────────────────────
export '../../domain/usecases/check_ad_access_usecase.dart' show DayPassStatus;
export '../../domain/usecases/watch_ad_for_access_usecase.dart'
    show WatchAdResult;

// ── State ─────────────────────────────────────────────────────────────────────

/// Immutable UI state for the DayPass management screen.
class DayPassState extends Equatable {
  final DayPassStatus status;
  final Duration remaining;
  final int adsWatchedThisSession;
  final bool isWatchingAd;
  final String? errorMessage;

  const DayPassState({
    required this.status,
    this.remaining = Duration.zero,
    this.adsWatchedThisSession = 0,
    this.isWatchingAd = false,
    this.errorMessage,
  });

  DayPassState copyWith({
    DayPassStatus? status,
    Duration? remaining,
    int? adsWatchedThisSession,
    bool? isWatchingAd,
    String? errorMessage,
  }) =>
      DayPassState(
        status: status ?? this.status,
        remaining: remaining ?? this.remaining,
        adsWatchedThisSession:
            adsWatchedThisSession ?? this.adsWatchedThisSession,
        isWatchingAd: isWatchingAd ?? this.isWatchingAd,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, remaining, adsWatchedThisSession, isWatchingAd, errorMessage];
}

// ── Provider ──────────────────────────────────────────────────────────────────

final dayPassProvider =
    AsyncNotifierProvider<DayPassNotifier, DayPassState>(DayPassNotifier.new);

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// ViewModel for [DayPassScreen].
///
/// Owns the countdown [Timer], calls [CheckAdAccessUseCase] and
/// [WatchAdForAccessUseCase]. The screen (View) is a dumb [ConsumerWidget]
/// that reads this state and delegates actions here.
class DayPassNotifier extends AsyncNotifier<DayPassState> {
  Timer? _timer;

  // ── Use case accessors ─────────────────────────────────────────────────────

  CheckAdAccessUseCase get _checkAccess =>
      CheckAdAccessUseCase(ref.read(daypassRepositoryProvider));

  WatchAdForAccessUseCase get _watchAdUseCase => WatchAdForAccessUseCase(
        ref.read(daypassRepositoryProvider),
        ref.read(admobServiceProvider),
      );

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  Future<DayPassState> build() async {
    ref.onDispose(() => _timer?.cancel());
    return _loadState();
  }

  Future<DayPassState> _loadState() async {
    final repo = ref.read(daypassRepositoryProvider);
    final status = await _checkAccess.call();
    final remaining = await repo.getDayPassRemainingDuration();
    _startTimer();
    return DayPassState(status: status, remaining: remaining);
  }

  // ── Timer ──────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.valueOrNull;
      if (current == null || current.isWatchingAd) return;
      if (current.remaining > Duration.zero) {
        state = AsyncData(
          current.copyWith(
              remaining: current.remaining - const Duration(seconds: 1)),
        );
      } else {
        // Pass expired mid-session — re-check from objectbox
        _reloadStatus();
      }
    });
  }

  Future<void> _reloadStatus() async {
    final repo = ref.read(daypassRepositoryProvider);
    final status = await _checkAccess.call();
    final remaining = await repo.getDayPassRemainingDuration();
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(status: status, remaining: remaining));
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Shows a rewarded ad. On [WatchAdResult.earned], stacks +24h and restarts
  /// the countdown timer. On failure, shows a typed error message.
  Future<bool> watchAd() async {
    final current = state.valueOrNull;
    if (current == null || current.isWatchingAd) return false;

    state = AsyncData(current.copyWith(isWatchingAd: true));

    final result = await _watchAdUseCase.call();
    final earned = result == WatchAdResult.earned;

    final errorMessage = switch (result) {
      WatchAdResult.earned => null,
      WatchAdResult.skipped => null, // user's choice — not an error
      WatchAdResult.loadFailed => 'Ad unavailable — try again in a moment',
      WatchAdResult.showFailed => 'Could not display ad — please retry',
      WatchAdResult.notReady => 'Ad service not ready — check your connection',
      WatchAdResult.alreadyInProgress => null,
    };

    final repo = ref.read(daypassRepositoryProvider);
    final newStatus = await _checkAccess.call();
    final newRemaining = await repo.getDayPassRemainingDuration();

    state = AsyncData(DayPassState(
      status: newStatus,
      remaining: newRemaining,
      adsWatchedThisSession: current.adsWatchedThisSession + (earned ? 1 : 0),
      isWatchingAd: false,
      errorMessage: errorMessage,
    ));

    if (earned) _startTimer(); // restart countdown with new expiry
    return earned;
  }

  /// Re-evaluates status from objectbox (e.g. after returning from paywall).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadState());
  }
}
