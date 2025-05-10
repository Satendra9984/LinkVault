// features/splash/data/repositories/splash_repository_impl.dart

import 'package:flutter/src/material/theme_data.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/core/theme/app_themes.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/splash/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/splash/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/splash/data/mappers/local_app_settings_mapper.dart';
import 'package:link_vault/src/splash/data/models/settings_model.dart';
import 'package:link_vault/src/splash/domain/repositories/local_app_settings_repository.dart';
import 'package:rxdart/subjects.dart';

class LocalAppSettingsRepositoryImpl implements LocalAppSettingsRepository {
  LocalAppSettingsRepositoryImpl({
    required LocalAppSettignsLocalDataSource local,
    required LocalAppSettingsRemoteDataSource remote,
    // required Isar isar,
  })  : _remote = remote,
        // _isar = isar,
        _local = local {
    // Initialize subjects with current values
    _initializeSubjects();

    // Listen to Isar Changes
    _setUpWatchers();
  }

  // final Isar _isar;
  final LocalAppSettignsLocalDataSource _local;
  final LocalAppSettingsRemoteDataSource _remote;

  // BehaviourSubjects for granular streams
  final _themeModeSubject = BehaviorSubject<Either<Failure, AppThemeEnums>>();
  final _settingsSubject = BehaviorSubject<Either<Failure, LocalAppSettings>>();
  final _hasSeenOnboardingSubject = BehaviorSubject<Either<Failure, bool>>();

  // TODO : HANDLE IS LOGGEDIN
  final _isLoggedInSubject = BehaviorSubject<bool>();

  Future<void> _initializeSubjects() async {
    final settings = await _local.getAppSettings();

    if (settings != null) {
      _updateSubjects(settings.toDomain());
    }
  }

  void _setUpWatchers() {
    _local.watchIsarAppSettings().listen(
      (settingsModel) {
        if (settingsModel != null) {
          final settings = settingsModel.toDomain();
          _updateSubjects(settings);
        }
      },
    );
  }

  void _updateSubjects(LocalAppSettings settings) {
    _settingsSubject.add(Right(settings));
    _themeModeSubject.add(Right(settings.themeMode));
    _hasSeenOnboardingSubject.add(Right(settings.hasSeenOnboarding));
  }

  @override
  Future<Either<Failure, LocalAppSettings>> getAppSettings() async {
    try {
      final model = await _local.getAppSettings() ?? IsarAppSettingsModel();

      return Right(model.toDomain());
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Could Not Get App-Settings.',
          statusCode: 400,
        ),
      );
    }
  }

  Future<LocalAppSettings> getSettings() async {
    final model = await _local.getAppSettings() ?? IsarAppSettingsModel();
    return model.toDomain();
  }

  @override
  Stream<Either<Failure, LocalAppSettings>> watchLocalAppSettings() {
    return _settingsSubject.stream;
  }

  @override
  Future<Either<Failure, void>> saveLocalAppSettings(
    LocalAppSettings settings,
  ) async {
    try {
      await _local.saveAppSettings(
        settings.toIsar(),
      );

      return const Right(Unit);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Could Not Save Settings',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> getIsLoggedIn() async {
    try {
      final loggedIn = _remote.isLoggedIn;

      return Right(loggedIn);
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Could Not Authencticate User.',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ThemeData>> getAppThemeMode() async {
    try {
      final appSettings = await _local.getAppSettings();
      if (appSettings == null) {
        return Left(
          CacheFailure(
            message: '',
            statusCode: 500,
          ),
        );
      }

      final appThemeData = AppThemes.getThemeDataFromString(
        appSettings.toDomain().themeMode.value,
      );

      return Right(appThemeData);
    } catch (e) {
      return Left(
        CacheFailure(
          message: '',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, AppThemeEnums>> watchThemeMode() {
    return _themeModeSubject.stream;
  }

  @override
  Future<Either<Failure, void>> saveThemeData(AppThemeEnums appTheme) async {
    try {
      final appSettingsIsar = await getSettings();
      final updatedAppSettings = appSettingsIsar.copyWith(themeMode: appTheme);

      final saved = await _local.saveAppSettings(updatedAppSettings.toIsar());

      return Right(saved);
    } catch (e) {
      return Left(
        CacheFailure(
          message: '',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, bool>> watchHasSeenOnboarding() {
    return _hasSeenOnboardingSubject.stream;
  }

  @override
  Future<Either<Failure, bool>> getHasSeenOnboarding() async {
    try {
      final appSettings = await _local.getAppSettings();
      if (appSettings == null) {
        return Left(
          CacheFailure(
            message: '',
            statusCode: 500,
          ),
        );
      }

      return Right(appSettings.seenOnboarding);
    } catch (e) {
      return Left(
        CacheFailure(
          message: '',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> setHasSeenOnboarding(
    bool hasSeenOnbaording,
  ) async {
    try {
      final appSettingsIsar = await getSettings();
      final updatedAppSettings =
          appSettingsIsar.copyWith(hasSeenOnboarding: hasSeenOnbaording);

      final saved = await _local.saveAppSettings(updatedAppSettings.toIsar());

      return Right(saved);
    } catch (e) {
      return Left(
        CacheFailure(
          message: '',
          statusCode: 500,
        ),
      );
    }
  }

  // ignore: public_member_api_docs
  void dispose() {
    _themeModeSubject.close();
    _settingsSubject.close();
    _hasSeenOnboardingSubject.close();
    _isLoggedInSubject.close();
  }
}
