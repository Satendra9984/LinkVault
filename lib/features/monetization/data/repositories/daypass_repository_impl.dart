import '../../domain/repositories/i_daypass_repository.dart';
import '../../../../core/data/repositories/app_settings_repository.dart';

/// Concrete [IDayPassRepository] implementation.
///
/// Delegates all operations to [AppSettingsRepository] so the DayPass feature
/// has its own clean data-layer entry point without duplicating storage code.
///
/// Registered via [daypassRepositoryProvider] in `core_providers.dart`.
class DayPassRepositoryImpl implements IDayPassRepository {
  final AppSettingsRepository _settings;

  const DayPassRepositoryImpl(this._settings);

  @override
  Future<DateTime?> getDayPassExpiresAt() => _settings.getDayPassExpiresAt();

  @override
  Future<Duration> getDayPassRemainingDuration() =>
      _settings.getDayPassRemainingDuration();

  @override
  Future<DateTime?> getLastAdWatchedAt() => _settings.getLastAdWatchedAt();

  @override
  Future<bool> lastAdFailed() => _settings.lastAdFailed();

  @override
  Future<DateTime?> getInstallDate() => _settings.getInstallDate();

  @override
  Future<void> setInstallDateIfNotSet() => _settings.setInstallDateIfNotSet();

  @override
  Future<bool> getCachedPremiumStatus() => _settings.getCachedPremiumStatus();

  @override
  Future<void> markAdWatched() => _settings.markAdWatched();

  @override
  Future<void> markAdFailed() => _settings.markAdFailed();

  @override
  Future<void> cachePremiumStatus({required bool isPremium}) =>
      _settings.cachePremiumStatus(isPremium: isPremium);
}
