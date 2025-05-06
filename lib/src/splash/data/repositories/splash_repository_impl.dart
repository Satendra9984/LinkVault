// features/splash/data/repositories/splash_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/splash/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/splash/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/splash/data/mappers/local_app_settings_mapper.dart';
import 'package:link_vault/src/splash/data/models/settings_model.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  SplashRepositoryImpl({
    required SplashLocalDataSource local,
    required SplashRemoteDataSource remote,
  })  : _remote = remote,
        _local = local;

  final SplashLocalDataSource _local;
  final SplashRemoteDataSource _remote;

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

  @override
  Future<Either<Failure, void>> saveAppSettings(
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
  Future<bool> getIfLoggedIn() async {
    final loggedIn = _remote.isLoggedIn;

    return loggedIn;
  }

  @override
  Future<bool> getIfSeenOnboarding() async {
    return _local.hasSeenOnboarding();
  }

  @override
  Future<void> setOnBoardingStatus(bool onBoardingStatus) async {
    await _local.setOnboardingStatus(onBoardingStatus);
  }
}
