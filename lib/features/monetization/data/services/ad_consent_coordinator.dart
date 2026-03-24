import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_logger.dart';

/// Runs **Google UMP** (consent form when required), then **iOS App Tracking
/// Transparency** when the user has not been asked yet.
///
/// Call this **before** [MobileAds.instance.initialize].
///
/// **AdMob Console:** create a **Privacy & messaging → GDPR** (and other)
/// message so UMP can show a form in regulated regions. Without it, the update
/// may succeed but consent UI depends on your AdMob configuration.
///
/// **Debug (dev + debug mode only):** optional `.env` keys:
/// - `ADMOB_UMP_TEST_DEVICE_IDS` — comma-separated [UMP test device
///   IDs](https://developers.google.com/admob/android/privacy/test-device-ids)
/// - `ADMOB_UMP_DEBUG_GEOGRAPHY` — `eea`, `us`, or `other` to simulate regions
class AdConsentCoordinator {
  AdConsentCoordinator._();

  static Future<void> gatherConsentThenAtt() async {
    try {
      await _requestConsentInfoUpdate();
      await ConsentForm.loadAndShowConsentFormIfRequired(_onFormDismissed);

      final canAds = await ConsentInformation.instance.canRequestAds();
      if (!canAds) {
        AppLogger.w(
          'AdConsentCoordinator: canRequestAds=false — ads may be limited',
        );
      }
    } catch (e, st) {
      AppLogger.e('AdConsentCoordinator: UMP flow failed', e, st);
    }

    await _requestIosAttIfNeeded();
  }

  static void _onFormDismissed(FormError? error) {
    if (error != null) {
      AppLogger.w(
        'AdConsentCoordinator: consent form '
        '[${error.errorCode}] ${error.message}',
      );
    }
  }

  static Future<void> _requestConsentInfoUpdate() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      _consentParams(),
      () {
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        AppLogger.w(
          'AdConsentCoordinator: requestConsentInfoUpdate '
          '[${error.errorCode}] ${error.message}',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  static ConsentRequestParameters _consentParams() {
    if (!kDebugMode || !AppConfig.instance.isDev) {
      return ConsentRequestParameters();
    }

    final raw = dotenv.env['ADMOB_UMP_TEST_DEVICE_IDS'] ?? '';
    final ids = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (ids.isEmpty) {
      return ConsentRequestParameters();
    }

    final geoRaw =
        dotenv.env['ADMOB_UMP_DEBUG_GEOGRAPHY']?.toLowerCase().trim();
    DebugGeography? geo;
    switch (geoRaw) {
      case 'eea':
        geo = DebugGeography.debugGeographyEea;
        break;
      case 'us':
      case 'regulated_us':
        geo = DebugGeography.debugGeographyRegulatedUsState;
        break;
      case 'other':
        geo = DebugGeography.debugGeographyOther;
        break;
      default:
        geo = null;
    }

    return ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: geo,
        testIdentifiers: ids,
      ),
    );
  }

  static Future<void> _requestIosAttIfNeeded() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status != TrackingStatus.notDetermined) return;

      // Avoid stacking the ATT prompt on top of the UMP sheet.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (e, st) {
      AppLogger.e('AdConsentCoordinator: ATT failed', e, st);
    }
  }
}
