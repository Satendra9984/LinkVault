// features/splash/domain/repositories/splash_repository.dart


import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';

abstract class SplashRepository {
  /// Returns login + first‑timer info
  Future<bool> getIfLoggedIn();
  Future<bool> getIfSeenOnboarding();
  Future<void> setOnBoardingStatus(bool hasSeenOnbaording);

    /// Returns the full set of persisted settings
  Future<Either<Failure, LocalAppSettings>> getAppSettings();

  /// Save an updated settings object
  Future<Either<Failure, void>> saveAppSettings(LocalAppSettings settings);
}
