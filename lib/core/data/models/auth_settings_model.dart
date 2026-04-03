import 'package:objectbox/objectbox.dart';

/// Singleton ObjectBox model (id always = 1) that stores all app-level flags.
@Entity()
class AuthSettingsModel {
  @Id(assignable: true)
  int id = 1;

  // ── Onboarding ──────────────────────
  bool hasSeenOnboarding = false;

  // ── Guest mode ───────────────────────
  bool isGuestMode = false;

  // ── DayPass (Free-tier ad gate) ──────
  @Property(type: PropertyType.date)
  DateTime? installDate;

  @Property(type: PropertyType.date)
  DateTime? lastAdWatchedAt;
  
  bool lastAdFailed = false;

  @Property(type: PropertyType.date)
  DateTime? offlineGracePeriodStart;

  @Property(type: PropertyType.date)
  DateTime? dayPassExpiresAt;

  /// When signed in, mirrors `lv_user_profiles.install_trial_consumed` so the
  /// 3-day install trial cannot be re-granted after reinstall (guests ignore).
  bool installTrialConsumedRemote = false;

  // ── RevenueCat cache ─────────────────
  bool isPremiumCached = false;

  // ── Cloud Migration ──────────────────
  bool hasMigratedToCloud = false;

  // ── Appearance ───────────────────────
  String themeMode = 'system';

  // ── Settings screen (persisted) ──────
  /// 0 = in-app browser, 1 = external browser
  int openLinksDefault = 0;

  bool showLinkPreviews = true;
  bool showFavicons = true;

  /// 0 = grid, 1 = list, 2 = compact
  int defaultFoldersLayout = 0;

  /// 0 = list, 1 = cards, 2 = icons
  int defaultLinksLayout = 0;

  bool autoSyncEnabled = true;
  bool syncWifiOnly = false;
  bool notifyLinkSaved = false;
  bool notifySyncComplete = false;
}
