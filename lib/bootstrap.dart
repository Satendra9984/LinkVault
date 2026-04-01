import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/infrastructure/database/app_database.dart';
import 'core/infrastructure/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/monetization/data/services/admob_service.dart';
import 'features/sync/domain/cloud_sync_trigger.dart';
import 'features/sync/presentation/providers/sync_coordinator_provider.dart';

/// Shared bootstrap logic called by both [main_dev.dart] and [main_production.dart].
/// Assumes dotenv has already been loaded before this is called.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppConfig from the already-loaded dotenv
  AppConfig.initialize();

  // Initialize objectbox + Supabase in parallel
  final appDatabase = AppDatabase();
  await Future.wait([
    appDatabase.init(),
    Supabase.initialize(
      url: AppConfig.instance.supabaseUrl,
      anonKey: AppConfig.instance.supabaseAnonKey,
    ),
  ]);

  // RevenueCat — platform key resolved by AppConfig
  final rcKey = AppConfig.instance.revenueCatKey;
  if (rcKey.isNotEmpty) {
    await Purchases.setLogLevel(
        AppConfig.instance.isDev ? LogLevel.debug : LogLevel.info);

    final configuration = PurchasesConfiguration(rcKey)
      ..storeKitVersion = StoreKitVersion.storeKit2;

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      configuration.appUserID = currentUserId;
    }

    await Purchases.configure(configuration);
    debugPrint(
        '💰 RevenueCat configured (${AppConfig.instance.environmentName})');
  } else {
    debugPrint('⚠️  RevenueCat key not set — subscriptions disabled');
  }

  // AdMob — fire SDK init in the background; does NOT block app startup.
  // AdmobService self-initialises on first ad request if this hasn't
  // finished yet, so the splash screen is never held waiting.
  AdmobService.initialize().then((_) {
    debugPrint('AdMob SDK ready (${AppConfig.instance.environmentName})');
  }).catchError((Object e) {
    debugPrint('AdMob SDK init failed (will retry on first ad): $e');
  });

  debugPrint(
    '🚀 LinkVault started in ${AppConfig.instance.environmentName} mode',
  );
  final supabaseHost = Uri.tryParse(AppConfig.instance.supabaseUrl)?.host;
  debugPrint(
    '🔎 Env diagnostics: env=${AppConfig.instance.environmentName}, supabaseHost=${supabaseHost ?? 'invalid'}',
  );
  final rewarded = AppConfig.instance.admobRewardedAdUnit;
  final rewardedPreview = rewarded.isEmpty
      ? 'MISSING'
      : rewarded.length <= 24
          ? rewarded
          : '${rewarded.substring(0, 14)}…';
  debugPrint(
    '🔎 AdMob rewarded unit: $rewardedPreview (${AppConfig.instance.isDev ? "dev/test" : "prod"})',
  );
  if (AppConfig.instance.isAdMobRewardedMisconfigured) {
    debugPrint(
      '⚠️ AdMob: production build has empty ADMOB_REWARDED_AD_UNIT_ID_* — rewarded ads disabled.',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDatabase),
      ],
      child: const LinkVaultApp(),
    ),
  );
}

class LinkVaultApp extends ConsumerStatefulWidget {
  const LinkVaultApp({super.key});

  @override
  ConsumerState<LinkVaultApp> createState() => _LinkVaultAppState();
}

class _LinkVaultAppState extends ConsumerState<LinkVaultApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ProviderScope.containerOf(context) gives us the container from the
    // ProviderScope above (in bootstrap). We need this to pass to
    // createAppRouter so the redirect guard can read providers.
    // We set listen: false because we only need the container once.
    final container = ProviderScope.containerOf(context, listen: false);
    _router = createAppRouter(container);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncCoordinatorProvider.notifier).runSync(
            manual: false,
            trigger: CloudSyncTrigger.bootstrap,
          );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncCoordinatorProvider.notifier).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    ref.watch(syncCoordinatorProvider);

    return MaterialApp.router(
      title: 'LinkVault',
      debugShowCheckedModeBanner: false, //AppConfig.instance.isDev,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.flutterThemeMode,
      routerConfig: _router,
    );
  }
}
