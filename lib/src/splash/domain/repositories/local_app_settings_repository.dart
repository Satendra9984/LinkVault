// features/splash/domain/repositories/splash_repository.dart

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';

abstract class LocalAppSettingsRepository {
  /// One Time Reads
  Future<Either<Failure, LocalAppSettings>> getAppSettings();
  Future<Either<Failure, bool>> getIsLoggedIn();
  Future<Either<Failure, ThemeData>> getAppThemeMode();
  Future<Either<Failure, bool>> getHasSeenOnboarding();

  // Continuous observation
  Stream<Either<Failure, LocalAppSettings>> watchLocalAppSettings();
  Stream<Either<Failure, AppThemeEnums>> watchThemeMode();
  Stream<Either<Failure, bool>> watchHasSeenOnboarding();
  // Stream<bool> watchIsLoggedIn();

  // Updates
  Future<Either<Failure, void>> saveLocalAppSettings(LocalAppSettings settings);
  Future<Either<Failure, void>> setHasSeenOnboarding(bool hasSeenOnbaording);
  Future<Either<Failure, void>> saveThemeData(AppThemeEnums appTheme);
}
