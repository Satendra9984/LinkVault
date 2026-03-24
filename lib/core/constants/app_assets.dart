class AppAssets {
  // Base Path
  static const String _imagesPath = 'assets/images';

  // Onboarding Illustrations
  static const String onboardingWelcome = '$_imagesPath/onboarding_welcome.png';
  static const String onboardingSave = '$_imagesPath/onboarding_save.png';
  static const String onboardingOrganize =
      '$_imagesPath/onboarding_organize.png';
  static const String onboardingAct = '$_imagesPath/onboarding_act.png';

  // Empty State Illustrations
  static const String emptyCollections = '$_imagesPath/empty_collections.png';
  static const String emptySearch = '$_imagesPath/empty_search.png';

  // Error Illustrations
  static const String errorNetwork = '$_imagesPath/error_network.png';

  // Monetization & Rewards
  static const String premiumHeader = '$_imagesPath/premium_header.png';
  static const String illustrationReward =
      '$_imagesPath/illustration_reward.png';

  // Branding & Logos
  static const String appLogoReference = '$_imagesPath/curate_logo_1024.png';

  // Helper method to get asset by name (if needed for dynamic loading)
  static String getImage(String imageName) => '$_imagesPath/$imageName';

  // Private constructor
  AppAssets._();
}
