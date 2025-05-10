// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/src/shared/shared_app_providers.dart';
import 'package:link_vault/src/splash/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/splash/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/splash/data/repositories/local_app_settings_repository_impl.dart';
import 'package:link_vault/src/splash/domain/usecases/watch_is_loggedin_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/watch_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/save_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/splash/presentation/blocs/splash_bloc/splash_bloc.dart';

final splashLocalDataSourceProvider = Provider((ref) {
  return LocalAppSettignsLocalDataSource(
    ref.watch(storageServiceProvider).isar,
  );
});

final splashRemoteDataSourceProvider = Provider((ref) {
  return LocalAppSettingsRemoteDataSource(
    ref.watch(storageServiceProvider).supabaseClient,
  );
});

final splashRepositoryProvider = Provider((ref) {
  return LocalAppSettingsRepositoryImpl(
    local: ref.watch(splashLocalDataSourceProvider),
    remote: ref.watch(splashRemoteDataSourceProvider),
  );
});

final getIsLoggedInProvider = Provider((ref) {
  return WatchIsLoggedinUsecase(
    ref.watch(splashRepositoryProvider),
  );
});

final getHasSeenOnboardingProvider = Provider((ref) {
  return WatchHasSeenOnboardingUsecase(
    ref.watch(splashRepositoryProvider),
  );
});

final setOnBoardingStatusUseCaseProvider = Provider((ref) {
  return SaveHasSeenOnboardingUsecase(
    ref.watch(splashRepositoryProvider),
  );
});

final splashBlocProvider = Provider((ref) {
  return SplashBloc(
    ref.watch(splashRepositoryProvider),
  );
});
