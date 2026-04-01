import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Defines the available application environments.
enum AppEnvironment { dev, production }

/// A singleton that provides environment-specific configuration
/// loaded from the appropriate `.env.*` file.
///
/// Access anywhere via [AppConfig.instance].
class AppConfig {
  AppConfig._();

  static AppConfig? _instance;

  /// The singleton instance. Must call [AppConfig.initialize] in [main] first.
  static AppConfig get instance {
    assert(_instance != null,
        'AppConfig not initialized. Call AppConfig.initialize() in main().');
    return _instance!;
  }

  late final AppEnvironment environment;

  // ── Supabase ────────────────────────────────────────────────────────────
  late final String supabaseUrl;
  late final String supabaseAnonKey;

  // ── RevenueCat ──────────────────────────────────────────────────────────
  late final String revenueCatIosKey;
  late final String revenueCatAndroidKey;

  // ── AdMob ───────────────────────────────────────────────────────────────
  late final String admobAppIdIos;
  late final String admobAppIdAndroid;
  late final String admobRewardedAdUnitIos;
  late final String admobRewardedAdUnitAndroid;

  /// Returns the correct RevenueCat key for the current platform.
  String get revenueCatKey => defaultTargetPlatform == TargetPlatform.iOS
      ? revenueCatIosKey
      : revenueCatAndroidKey;

  /// Google-provided **sample** rewarded units (safe for dev when .env is empty).
  static const String _googleTestRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _googleTestRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';

  /// Returns the correct AdMob rewarded ad unit ID for the current platform.
  /// In dev, prefers `ADMOB_TEST_*` from .env, then Google's official test IDs.
  String get admobRewardedAdUnit {
    if (isDev) {
      final fromEnv = defaultTargetPlatform == TargetPlatform.iOS
          ? dotenv.env['ADMOB_TEST_REWARDED_AD_UNIT_ID_IOS']
          : dotenv.env['ADMOB_TEST_REWARDED_AD_UNIT_ID_ANDROID'];
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        return fromEnv.trim();
      }
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _googleTestRewardedIos
          : _googleTestRewardedAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? admobRewardedAdUnitIos
        : admobRewardedAdUnitAndroid;
  }

  /// True when production build has no rewarded unit configured (misconfiguration).
  bool get isAdMobRewardedMisconfigured =>
      isProduction &&
      (defaultTargetPlatform == TargetPlatform.iOS
          ? admobRewardedAdUnitIos.isEmpty
          : admobRewardedAdUnitAndroid.isEmpty);

  /// Initializes the config from the loaded dotenv values.
  /// Must be called after [dotenv.load()] in main.
  static void initialize() {
    final instance = AppConfig._();

    final env = dotenv.env['APP_ENV'] ?? 'dev';
    instance.environment =
        env == 'production' ? AppEnvironment.production : AppEnvironment.dev;

    instance.supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    instance.supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    instance.revenueCatIosKey = dotenv.env['REVENUE_CAT_IOS_KEY'] ?? '';
    instance.revenueCatAndroidKey = dotenv.env['REVENUE_CAT_ANDROID_KEY'] ?? '';
    instance.admobAppIdIos = dotenv.env['ADMOB_APP_ID_IOS'] ?? '';
    instance.admobAppIdAndroid = dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '';
    instance.admobRewardedAdUnitIos =
        dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_IOS'] ?? '';
    instance.admobRewardedAdUnitAndroid =
        dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_ANDROID'] ?? '';

    assert(instance.supabaseUrl.isNotEmpty,
        'SUPABASE_URL is missing from .env file');
    assert(instance.supabaseAnonKey.isNotEmpty,
        'SUPABASE_ANON_KEY is missing from .env file');

    _instance = instance;
  }

  /// Returns true when running in the development environment.
  bool get isDev => environment == AppEnvironment.dev;

  /// Returns true when running in the production environment.
  bool get isProduction => environment == AppEnvironment.production;

  /// Human-readable environment name for display/logging.
  String get environmentName => isDev ? 'Development' : 'Production';
}
