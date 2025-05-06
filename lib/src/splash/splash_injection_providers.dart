// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/src/splash/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/splash/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/splash/data/repositories/splash_repository_impl.dart';
import 'package:link_vault/src/splash/domain/usecases/check_if_loggedin_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/get_if_fist_timer.dart';
import 'package:link_vault/src/splash/domain/usecases/set_onboarding_status_usecase.dart';
import 'package:link_vault/src/splash/presentation/bloc/splash_bloc.dart';

final splashLocalDataSourceProvider = Provider((ref) {
  return SplashLocalDataSource(ref.watch(storageServiceProvider).isar);
});

final splashRemoteDataSourceProvider = Provider((ref) {
  return SplashRemoteDataSource(
      ref.watch(storageServiceProvider).supabaseClient);
});

final splashRepositoryProvider = Provider((ref) {
  return SplashRepositoryImpl(
    local: ref.watch(splashLocalDataSourceProvider),
    remote: ref.watch(splashRemoteDataSourceProvider),
  );
});

final getIfLoggedInProvider = Provider((ref) {
  return GetLoggedInStatus(
    ref.watch(splashRepositoryProvider),
  );
});

final getIfSeenOnboardingProvider = Provider((ref) {
  return GetIfFistTimer(
    ref.watch(splashRepositoryProvider),
  );
});

final setOnBoardingStatusUseCaseProvider = Provider((ref) {
  return SetOnboardingStatusUsecase(
    ref.watch(splashRepositoryProvider),
  );
});

final splashBlocProvider = Provider((ref) {
  return SplashBloc(
    ref.watch(splashRepositoryProvider),
    // getIfFistTimer: ref.watch(getIfSeenOnboardingProvider),
    // getLoggedInStatus: ref.watch(getIfLoggedInProvider),
    // setOnBoardingStatus: ref.watch(setOnBoardingStatusUseCaseProvider),
  );
});
