/// Central registry for all image assets.
///
/// Rules:
/// - Every file in assets/images/ MUST have a constant here.
/// - No code outside this file should use a raw 'assets/images/...' string.
/// - All current images are WebP (smaller, lossless-quality).
///   The launcher icon uses the original PNG (linkvault_logo.png) because
///   flutter_launcher_icons requires PNG input.
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/images';

  // ── Branding ──────────────────────────────────────────────────────────────

  /// App logo shown in the splash screen and About page (new design).
  static const String appLogo = '$_img/linkvault_logo.webp';

  /// Launcher logo PNG — used ONLY as the flutter_launcher_icons source.
  /// Do not reference this from UI code; use [appLogo] instead.
  static const String appLogoPng = '$_img/linkvault_logo.png';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static const String onboardingWelcome  = '$_img/onboarding_welcome.webp';
  static const String onboardingSave     = '$_img/onboarding_save.webp';
  static const String onboardingOrganize = '$_img/onboarding_organize.webp';
  static const String onboardingAct      = '$_img/onboarding_act.webp';

  // ── Empty States ──────────────────────────────────────────────────────────

  static const String emptyCollections = '$_img/empty_collections.webp';
  static const String emptyLinks       = '$_img/empty_links.webp';
  static const String emptySearch      = '$_img/empty_search.webp';

  // ── Error States ──────────────────────────────────────────────────────────

  static const String errorNetwork = '$_img/error_network.webp';
}
