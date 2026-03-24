import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_logger.dart';
import 'ad_consent_coordinator.dart';

// ── Result type ───────────────────────────────────────────────────────────────

/// Outcome returned by [AdmobService.showRewardedAd].
enum AdResult {
  /// User watched the full ad and earned the reward.
  earned,

  /// Ad loaded but user dismissed before earning (skipped).
  skipped,

  /// Ad failed to load after all retries (network/fill/device issue).
  loadFailed,

  /// Ad loaded but failed to display (activity state, overlay, etc.).
  showFailed,

  /// No ad unit ID configured.
  notConfigured,

  /// Another ad is already in progress (concurrency guard).
  alreadyShowing,

  /// SDK init timed out or device not supported.
  sdkNotReady,
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Wraps the AdMob [RewardedAd] lifecycle with:
/// - **Lazy init**: SDK is initialised on first use, not at app startup
/// - **Preloading**: an ad is fetched in the background after init
/// - **Retry with backoff**: 3 attempts, delays of 1s → 2s → 4s
/// - **Concurrency guard**: only one ad session runs at a time
/// - **Typed result**: callers get [AdResult], not a raw bool
class AdmobService {
  // ── Singleton ─────────────────────────────────────────────────────────────

  /// The shared instance used by providers after SDK init.
  static final AdmobService _instance = AdmobService._();
  AdmobService._();

  // ── SDK init ──────────────────────────────────────────────────────────────

  static bool _sdkInitialized = false;
  static Completer<void>? _initCompleter;

  /// Initialises the Mobile Ads SDK (idempotent).
  ///
  /// Calling this from [bootstrap.dart] is now OPTIONAL — the service
  /// self-initialises before any ad attempt. Kick it off early only to
  /// pre-warm the SDK pipeline without blocking app startup.
  static Future<void> initialize() async {
    if (_sdkInitialized) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();
    try {
      await AdConsentCoordinator.gatherConsentThenAtt();
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
      AppLogger.i('AdmobService: SDK initialized');
      _initCompleter!.complete();
    } catch (e, st) {
      AppLogger.e('AdmobService: SDK init failed', e, st);
      _initCompleter!.completeError(e, st);
      _initCompleter = null; // allow retry on next call
    }
    // Pre-warm the ad pipeline using the shared instance
    unawaited(_instance._preloadAd());
  }

  // ── Preload cache ─────────────────────────────────────────────────────────

  RewardedAd? _cachedAd;
  bool _isPreloading = false;
  bool _isBusy = false; // concurrency guard

  /// Silently loads an ad into [_cachedAd] so the next [showRewardedAd] call
  /// shows instantly. Errors are swallowed — this is best-effort only.
  Future<void> _preloadAd() async {
    if (_isPreloading || _cachedAd != null) return;
    final adUnitId = AppConfig.instance.admobRewardedAdUnit;
    if (adUnitId.isEmpty) return;

    _isPreloading = true;
    AppLogger.d('AdmobService: Preloading ad…');

    try {
      _cachedAd = await _loadWithRetry(adUnitId, maxAttempts: 3);
      if (_cachedAd != null) {
        AppLogger.i('AdmobService: Ad pre-cached ✓');
      }
    } catch (_) {
      // Swallow — preload is best-effort
    } finally {
      _isPreloading = false;
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Loads (or uses cached) and shows a rewarded ad.
  ///
  /// Returns an [AdResult] describing the outcome. Callers should treat
  /// [AdResult.earned] as the only success case.
  Future<AdResult> showRewardedAd() async {
    // 1. Concurrency guard
    if (_isBusy) {
      AppLogger.w('AdmobService: Ignoring call — ad already in progress');
      return AdResult.alreadyShowing;
    }

    // 2. Unit ID check
    final adUnitId = AppConfig.instance.admobRewardedAdUnit;
    if (adUnitId.isEmpty) {
      AppLogger.w('AdmobService: No ad unit ID configured');
      return AdResult.notConfigured;
    }

    // 3. Ensure SDK is ready
    if (!_sdkInitialized) {
      AppLogger.d('AdmobService: SDK not ready — initializing now…');
      try {
        await initialize().timeout(const Duration(seconds: 10));
      } on TimeoutException {
        AppLogger.w('AdmobService: SDK init timed out');
        return AdResult.sdkNotReady;
      } catch (e) {
        AppLogger.e('AdmobService: SDK init error on demand', e);
        return AdResult.sdkNotReady;
      }
    }

    _isBusy = true;
    try {
      return await _showInternal(adUnitId);
    } finally {
      _isBusy = false;
      // Pre-warm next ad immediately after the session ends
      _preloadAd();
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<AdResult> _showInternal(String adUnitId) async {
    // Use cached ad if available, otherwise load fresh (with retries)
    RewardedAd? ad;
    if (_cachedAd != null) {
      AppLogger.d('AdmobService: Using pre-cached ad');
      ad = _cachedAd;
      _cachedAd = null;
    } else {
      AppLogger.d('AdmobService: No cached ad — loading with retry…');
      ad = await _loadWithRetry(adUnitId, maxAttempts: 3);
    }

    if (ad == null) {
      AppLogger.w('AdmobService: All load attempts failed');
      return AdResult.loadFailed;
    }

    return _showAd(ad);
  }

  /// Loads a [RewardedAd] with exponential back-off.
  /// Returns `null` if all [maxAttempts] fail.
  Future<RewardedAd?> _loadWithRetry(String adUnitId,
      {required int maxAttempts}) async {
    // Back-off delays: 0s, 1s, 2s (first attempt is immediate)
    const delays = [Duration.zero, Duration(seconds: 1), Duration(seconds: 2)];

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        final delay = attempt <= delays.length
            ? delays[attempt - 1]
            : const Duration(seconds: 4);
        AppLogger.d(
            'AdmobService: Retry $attempt/$maxAttempts after ${delay.inSeconds}s…');
        await Future.delayed(delay);
      }

      final ad = await _loadOnce(adUnitId);
      if (ad != null) return ad;
    }
    return null;
  }

  /// Single load attempt. Returns the [RewardedAd] on success, `null` on failure.
  Future<RewardedAd?> _loadOnce(String adUnitId) async {
    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.i('AdmobService: Ad loaded');
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          AppLogger.w(
              'AdmobService: Load failed [code:${error.code}] ${error.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        AppLogger.w('AdmobService: Load timed out');
        return null;
      },
    );
  }

  /// Shows a loaded [RewardedAd] and waits for the user to earn / skip / fail.
  Future<AdResult> _showAd(RewardedAd ad) async {
    final completer = Completer<AdResult>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.d('AdmobService: Ad dismissed (skipped)');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(AdResult.skipped);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.w('AdmobService: Failed to show — $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(AdResult.showFailed);
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (_, reward) {
          AppLogger.i(
              'AdmobService: Reward earned (${reward.amount} ${reward.type})');
          if (!completer.isCompleted) completer.complete(AdResult.earned);
        },
      );
    } catch (e, st) {
      AppLogger.e('AdmobService: Exception calling show()', e, st);
      ad.dispose();
      return AdResult.showFailed;
    }

    // Ad could theoretically stay open forever — cap at 3 minutes
    return completer.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        AppLogger.w('AdmobService: Ad session timed out (3 min cap)');
        return AdResult.skipped;
      },
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Shared singleton (backward-compat). Prefer [admobServiceProvider] in new code.
final admobService = AdmobService._instance;

/// Riverpod [Provider] — always returns the shared singleton.
final admobServiceProvider =
    Provider<AdmobService>((ref) => AdmobService._instance);
