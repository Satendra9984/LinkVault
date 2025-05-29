import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/app_initializaiton/domain/repositories/local_app_settings_repository.dart';

class WatchThemedataUsecase {
  final LocalAppSettingsRepository repository;

  WatchThemedataUsecase(this.repository);

  Stream<Either<Failure, AppThemeEnums>> call() => repository.watchThemeMode();
}
