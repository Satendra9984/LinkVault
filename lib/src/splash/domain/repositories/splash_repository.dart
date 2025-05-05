// features/splash/domain/repositories/splash_repository.dart


abstract class SplashRepository {
  /// Returns login + first‑timer info
  Future<bool> getIfLoggedIn();
  Future<bool> getIfSeenOnboarding();
  Future<void> setOnBoardingStatus(bool hasSeenOnbaording);
}
