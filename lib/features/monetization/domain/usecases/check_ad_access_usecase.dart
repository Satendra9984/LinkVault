import '../repositories/i_daypass_repository.dart';
import '../../../../core/utils/app_logger.dart';

/// The five possible states of the free-tier Ad DayPass gate.
enum DayPassStatus {
  /// RevenueCat entitlement active — gate bypassed entirely.
  premium,

  /// Within the 3-day free trial window (no ads at all).
  freeTrial,

  /// A DayPass is currently valid (dayPassExpiresAt in the future).
  active,

  /// Ad gate shows — user must watch a rewarded ad to continue.
  expired,

  /// Grace period active: offline or last ad failed to load.
  grace,
}

/// Determines the current DayPass access status by reading from [IDayPassRepository].
/// Pure read-only — safe for UI use. Returns a typed [DayPassStatus] enum value.
class CheckAdAccessUseCase {
  final IDayPassRepository _repository;

  const CheckAdAccessUseCase(this._repository);

  Future<DayPassStatus> call() async {
    // 1. Premium users bypass everything.
    final isPremiumCached = await _repository.getCachedPremiumStatus();
    if (isPremiumCached) {
      AppLogger.d('DayPass: premium cached — bypassing gate');
      return DayPassStatus.premium;
    }

    // 2. Ensure install date is stamped (first call on fresh install).
    await _repository.setInstallDateIfNotSet();
    final installDate = await _repository.getInstallDate();

    if (installDate != null) {
      final daysSinceInstall =
          DateTime.now().difference(installDate).inHours / 24;
      if (daysSinceInstall < 3) {
        AppLogger.d(
            'DayPass: free trial (${daysSinceInstall.toStringAsFixed(1)} days since install)');
        return DayPassStatus.freeTrial;
      }
    }

    // 3. Check active DayPass via absolute expiry timestamp (stacking logic).
    final expiresAt = await _repository.getDayPassExpiresAt();
    if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
      final remaining = expiresAt.difference(DateTime.now());
      AppLogger.d(
          'DayPass: active (${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining)');
      return DayPassStatus.active;
    }

    // 3b. Legacy fallback: check lastAdWatchedAt for existing installs.
    final lastAdWatchedAt = await _repository.getLastAdWatchedAt();
    if (lastAdWatchedAt != null) {
      final hoursSinceAd = DateTime.now().difference(lastAdWatchedAt).inHours;
      if (hoursSinceAd < 24) {
        AppLogger.d(
            'DayPass: active legacy (ad watched $hoursSinceAd hrs ago)');
        return DayPassStatus.active;
      }
    }

    // 4. Grace period — last ad failed to load.
    final adFailed = await _repository.lastAdFailed();
    if (adFailed) {
      AppLogger.d('DayPass: grace (last ad failed to load)');
      return DayPassStatus.grace;
    }

    // 5. Gate expired — user must watch an ad.
    AppLogger.d('DayPass: expired — showing ad gate');
    return DayPassStatus.expired;
  }

  /// Returns how long remains on the current DayPass (for countdown UI).
  /// Returns [Duration.zero] if not active.
  Future<Duration> remainingDuration() =>
      _repository.getDayPassRemainingDuration();
}
