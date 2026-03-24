/// Abstract contract for all DayPass-specific persistence operations.
///
/// Lives in the domain layer — no objectbox, no Flutter imports.
/// [DayPassRepositoryImpl] in the data layer provides the concrete implementation.
abstract class IDayPassRepository {
  // ── Read: access state ─────────────────────────────────────────────────────

  /// Returns the absolute expiry timestamp of the current stacked DayPass,
  /// or `null` if no pass has ever been granted.
  Future<DateTime?> getDayPassExpiresAt();

  /// Returns the remaining duration on the current DayPass.
  /// Falls back to `lastAdWatchedAt + 24h` for legacy installs.
  /// Returns [Duration.zero] when expired or never granted.
  Future<Duration> getDayPassRemainingDuration();

  /// Returns when the last rewarded ad was successfully watched (legacy field).
  Future<DateTime?> getLastAdWatchedAt();

  /// Returns whether the most recent ad attempt failed (triggers grace period).
  Future<bool> lastAdFailed();

  // ── Read: user profile ──────────────────────────────────────────────────────

  /// Returns the app install date (used for the 3-day free-trial window).
  Future<DateTime?> getInstallDate();

  /// Stamps the install date exactly once on first launch.
  Future<void> setInstallDateIfNotSet();

  /// Returns the locally-cached premium status (avoids a RevenueCat call on
  /// every gate check).
  Future<bool> getCachedPremiumStatus();

  // ── Write ────────────────────────────────────────────────────────────────────

  /// Updates `dayPassExpiresAt` by stacking +24 h onto the current expiry
  /// (or from now if already expired). Also updates `lastAdWatchedAt`.
  Future<void> markAdWatched();

  /// Records that the last ad attempt failed, activating the grace period.
  Future<void> markAdFailed();

  /// Caches the current premium entitlement status locally.
  Future<void> cachePremiumStatus({required bool isPremium});
}
