import '../../../../objectbox.g.dart';
import '../../../features/settings/data/models/app_settings_model.dart';
import '../models/auth_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-level settings stored as a singleton [AuthSettingsModel]
/// row in ObjectBox (id = 1).
///
/// Sprint 1–2 requirement: onboarding completion uses SharedPreferences so
/// the app can skip onboarding across reinstalls without requiring ObjectBox
/// model migrations.
class AppSettingsRepository {
  final Store _store;
  late final Box<AuthSettingsModel> _box;

  static const String _hasSeenOnboardingKey = 'lv_has_seen_onboarding';

  AppSettingsRepository(this._store) {
    _box = _store.box<AuthSettingsModel>();
  }

  // ── Internal get/save ────────────────────────────────────────────────────

  Future<AuthSettingsModel> _get() async => _box.get(1) ?? AuthSettingsModel();

  Future<void> _save(AuthSettingsModel s) async => _box.put(s);

  // ── Onboarding ────────────────────────────────────────────────────────────
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // ── Guest Mode ────────────────────────────────────────────────────────────

  Future<bool> isGuestMode() async => (await _get()).isGuestMode;

  Future<void> setGuestMode({required bool value}) async =>
      _save((await _get())..isGuestMode = value);

  // ── Install trial (account mirror; see [AuthSettingsModel.installTrialConsumedRemote])
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> getInstallTrialConsumedRemote() async =>
      (await _get()).installTrialConsumedRemote;

  Future<void> setInstallTrialConsumedRemote({required bool value}) async =>
      _save((await _get())..installTrialConsumedRemote = value);

  // ── Install Date (DayPass 3-day trial) ───────────────────────────────────

  Future<DateTime?> getInstallDate() async => (await _get()).installDate;

  /// Sets the install date only once (on first app launch).
  Future<void> setInstallDateIfNotSet() async {
    final s = await _get();
    if (s.installDate == null) {
      await _save(s..installDate = DateTime.now());
    }
  }

  /// Time until the 3-day install trial ends (from [installDate]), or zero if past end.
  Future<Duration> getFreeTrialRemainingDuration() async {
    final install = await getInstallDate();
    if (install == null) return Duration.zero;
    final trialEnd = install.add(const Duration(days: 3));
    final r = trialEnd.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  // ── DayPass ───────────────────────────────────────────────────────────────

  Future<DateTime?> getLastAdWatchedAt() async =>
      (await _get()).lastAdWatchedAt;

  /// Returns the absolute expiry time of the current stacked DayPass.
  Future<DateTime?> getDayPassExpiresAt() async =>
      (await _get()).dayPassExpiresAt;

  /// Returns how long remains on the current DayPass, or Duration.zero
  /// if expired / never set. Falls back to lastAdWatchedAt+24h for
  /// installs that don't yet have dayPassExpiresAt written.
  Future<Duration> getDayPassRemainingDuration() async {
    final s = await _get();
    // Prefer the new absolute expiry field
    if (s.dayPassExpiresAt != null) {
      final remaining = s.dayPassExpiresAt!.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    }
    // Legacy fallback: lastAdWatchedAt + 24 hrs
    if (s.lastAdWatchedAt != null) {
      final legacyExpiry = s.lastAdWatchedAt!.add(const Duration(hours: 24));
      final remaining = legacyExpiry.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    }
    return Duration.zero;
  }

  /// Extends the DayPass by 24 hours from the current expiry (stacking).
  /// If already expired, starts a fresh 24hr pass from now.
  Future<void> markAdWatched() async {
    final s = await _get();
    final now = DateTime.now();
    final currentExpiry = s.dayPassExpiresAt;
    // Stack from current expiry if still valid, otherwise from now
    final base = (currentExpiry != null && currentExpiry.isAfter(now))
        ? currentExpiry
        : now;
    await _save(s
      ..dayPassExpiresAt = base.add(const Duration(hours: 24))
      ..lastAdWatchedAt = now
      ..lastAdFailed = false);
  }

  Future<void> markAdFailed() async =>
      _save((await _get())..lastAdFailed = true);

  Future<bool> lastAdFailed() async => (await _get()).lastAdFailed;

  // ── Premium Cache ─────────────────────────────────────────────────────────

  Future<bool> getCachedPremiumStatus() async => (await _get()).isPremiumCached;

  Future<void> cachePremiumStatus({required bool isPremium}) async =>
      _save((await _get())..isPremiumCached = isPremium);

  // ── Appearance ────────────────────────────────────────────────────────────

  Future<String> getThemeMode() async => (await _get()).themeMode;

  Future<void> setThemeMode(String mode) async {
    final s = await _get();
    await _save(s..themeMode = mode);
  }

  // ── Settings screen (link / layout / sync / notifications) ────────────────

  Future<int> getOpenLinksDefault() async => (await _get()).openLinksDefault;

  Future<void> setOpenLinksDefault(int index) async =>
      _save((await _get())..openLinksDefault = index);

  Future<bool> getShowLinkPreviews() async => (await _get()).showLinkPreviews;

  Future<void> setShowLinkPreviews(bool value) async =>
      _save((await _get())..showLinkPreviews = value);

  Future<bool> getShowFavicons() async => (await _get()).showFavicons;

  Future<void> setShowFavicons(bool value) async =>
      _save((await _get())..showFavicons = value);

  Future<int> getDefaultFoldersLayout() async =>
      (await _get()).defaultFoldersLayout;

  Future<void> setDefaultFoldersLayout(int index) async =>
      _save((await _get())..defaultFoldersLayout = index);

  Future<int> getDefaultLinksLayout() async =>
      (await _get()).defaultLinksLayout;

  Future<void> setDefaultLinksLayout(int index) async =>
      _save((await _get())..defaultLinksLayout = index);

  Future<bool> getAutoSyncEnabled() async => (await _get()).autoSyncEnabled;

  Future<void> setAutoSyncEnabled(bool value) async =>
      _save((await _get())..autoSyncEnabled = value);

  Future<bool> getSyncWifiOnly() async => (await _get()).syncWifiOnly;

  Future<void> setSyncWifiOnly(bool value) async =>
      _save((await _get())..syncWifiOnly = value);

  Future<bool> getNotifyLinkSaved() async => (await _get()).notifyLinkSaved;

  Future<void> setNotifyLinkSaved(bool value) async =>
      _save((await _get())..notifyLinkSaved = value);

  Future<bool> getNotifySyncComplete() async =>
      (await _get()).notifySyncComplete;

  Future<void> setNotifySyncComplete(bool value) async =>
      _save((await _get())..notifySyncComplete = value);

  // ── Reset (e.g., on sign-out) ─────────────────────────────────────────────

  /// Clears guest mode, premium cache, and cloud migration flags on sign-out.
  /// Preserves onboarding flag and install date so new users on the same
  /// device keep Day Pass trial continuity.
  Future<void> clearSessionData() async {
    final s = await _get();
    await _save(s
      ..isGuestMode = false
      ..isPremiumCached = false
      ..installTrialConsumedRemote = false
      ..lastAdWatchedAt = null
      ..lastAdFailed = false
      ..dayPassExpiresAt = null
      ..hasMigratedToCloud = false);

    // Legacy [AppSettingsModel] row (used by [hasMigratedToCloudProvider]).
    final appBox = _store.box<AppSettingsModel>();
    final legacy = appBox.query().build().findFirst();
    if (legacy != null) {
      legacy.hasMigratedToCloud = false;
      appBox.put(legacy);
    }
  }

  // ── Cloud Migration ────────────────────────────────────────────────────────

  /// Returns true if the current session has already migrated local data
  /// to Supabase. Stored in [AuthSettingsModel] so it resets on sign-out.
  Future<bool> hasMigratedToCloud() async => (await _get()).hasMigratedToCloud;

  /// Marks the local→cloud migration as completed for this session.
  Future<void> setMigratedToCloud({required bool value}) async =>
      _save((await _get())..hasMigratedToCloud = value);
}
