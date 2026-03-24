import '../repositories/i_daypass_repository.dart';
import '../../data/services/admob_service.dart';

/// Result of a single ad-watch attempt at the domain layer.
enum WatchAdResult {
  /// User watched the full ad — DayPass extended by +24h.
  earned,

  /// Ad loaded but user dismissed it before earning.
  skipped,

  /// Ad could not load after all retries (network / no fill).
  loadFailed,

  /// Ad loaded but the system couldn't display it (show error).
  showFailed,

  /// SDK not ready or no ad unit configured.
  notReady,

  /// Another watch is already in progress.
  alreadyInProgress,
}

/// Shows a rewarded ad and records the result in [IDayPassRepository].
///
/// - [WatchAdResult.earned]  → [IDayPassRepository.markAdWatched] (+24h stacked)
/// - Any failure             → [IDayPassRepository.markAdFailed] (grace period)
///
/// Callers should treat [WatchAdResult.earned] as the only success case.
class WatchAdForAccessUseCase {
  final IDayPassRepository _repository;
  final AdmobService _adService;

  const WatchAdForAccessUseCase(this._repository, this._adService);

  Future<WatchAdResult> call() async {
    final adResult = await _adService.showRewardedAd();

    switch (adResult) {
      case AdResult.earned:
        await _repository.markAdWatched();
        return WatchAdResult.earned;

      case AdResult.skipped:
        // Skipped ≠ failure — no grace period, just no reward
        return WatchAdResult.skipped;

      case AdResult.loadFailed:
        await _repository.markAdFailed();
        return WatchAdResult.loadFailed;

      case AdResult.showFailed:
        await _repository.markAdFailed();
        return WatchAdResult.showFailed;

      case AdResult.notConfigured:
      case AdResult.sdkNotReady:
        return WatchAdResult.notReady;

      case AdResult.alreadyShowing:
        return WatchAdResult.alreadyInProgress;
    }
  }
}
