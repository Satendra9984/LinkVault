// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_settings_usecase.dart';
import 'package:link_vault/src/shared/shared_app_providers.dart';
import 'package:link_vault/src/app_initializaiton/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/app_initializaiton/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/app_initializaiton/data/repositories/local_app_settings_repository_impl.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_is_loggedin_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/watch_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/save_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/splash_bloc/splash_bloc.dart';

final localAppSettingsLocalDataSourceProvider = Provider((ref) {
  return LocalAppSettignsLocalDataSource(
    ref.watch(storageServiceProvider).isar,
  );
});

final localAuthDataSourceProvider = Provider((ref) {
  return LocalAppSettingsRemoteDataSource(
    ref.watch(storageServiceProvider).supabaseClient,
  );
});

final splashRepositoryProvider = Provider((ref) {
  return LocalAppSettingsRepositoryImpl(
    local: ref.watch(localAppSettingsLocalDataSourceProvider),
    remote: ref.watch(localAuthDataSourceProvider),
  );
});

final localAppSettingsRepositoryProvider = Provider(
  (ref) {
    return LocalAppSettingsRepositoryImpl(
      local: ref.watch(localAppSettingsLocalDataSourceProvider),
      remote: ref.watch(localAuthDataSourceProvider),
    );
  },
);

final getLocalAppSettingsUsecaseProvider = Provider((ref) {
  return GetSettingsUsecase(
    ref.watch(splashRepositoryProvider),
  );
});

final getIsLoggedInProvider = Provider((ref) {
  return GetIsLoggedinUsecase(
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
    ref.watch(getIsLoggedInProvider),
    ref.watch(getLocalAppSettingsUsecaseProvider),
  );
});
