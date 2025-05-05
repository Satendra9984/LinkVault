// features/splash/data/repositories/splash_repository_impl.dart

import 'package:link_vault/src/splash/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/splash/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource _local;
  final SplashRemoteDataSource _remote;

  SplashRepositoryImpl({
    required SplashLocalDataSource local,
    required SplashRemoteDataSource remote,
  })  : _remote = remote,
        _local = local;

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
