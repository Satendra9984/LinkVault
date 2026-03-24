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

  // ── RevenueCat cache ─────────────────
  bool isPremiumCached = false;

  // ── Cloud Migration ──────────────────
  bool hasMigratedToCloud = false;

  // ── Appearance ───────────────────────
  String themeMode = 'system';
}
