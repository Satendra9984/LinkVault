// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/src/app_initializaiton/data/datasources/splash_local_data_source.dart';
import 'package:link_vault/src/app_initializaiton/data/datasources/splash_remote_data_source.dart';
import 'package:link_vault/src/app_initializaiton/data/repositories/local_app_settings_repository_impl.dart';
import 'package:link_vault/src/app_initializaiton/data/repositories/onboarding_repository_impl.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_is_loggedin_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_onboarding_pages_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_settings_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/save_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/save_thememode_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/watch_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/watch_themedata_usecase.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/app_theme_cubit/app_theme_cubit.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/splash_bloc/splash_bloc.dart';
import 'package:link_vault/src/shared/shared_app_providers.dart';

/// CORE INITIALIZATION PROVIDRS
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

final localSettingsRepositoryProvider = Provider((ref) {
  return LocalAppSettingsRepositoryImpl(
    local: ref.watch(localAppSettingsLocalDataSourceProvider),
    remote: ref.watch(localAuthDataSourceProvider),
  );
});

/// SPLASH RELATED PROVIDERS
final getLocalAppSettingsUsecaseProvider = Provider((ref) {
  return GetSettingsUsecase(
    ref.watch(localSettingsRepositoryProvider),
  );
});

final getIsLoggedInProvider = Provider((ref) {
  return GetIsLoggedinUsecase(
    ref.watch(localSettingsRepositoryProvider),
  );
});

final splashBlocProvider = Provider((ref) {
  return SplashBloc(
    ref.watch(getIsLoggedInProvider),
    ref.watch(getLocalAppSettingsUsecaseProvider),
  );
});

/// THEMEDATA RELATED PROVIDERS
final watchThemedataUsecaseProvider = Provider(
  (ref) {
    return WatchThemedataUsecase(
      ref.watch(localSettingsRepositoryProvider),
    );
  },
);

final saveThemeModeUseCaseProvider = Provider(
  (ref) {
    return SaveThememodeUsecase(
      ref.watch(localSettingsRepositoryProvider),
    );
  },
);

final themeBlocProvider = Provider(
  (ref) {
    return AppThemeCubit(
      ref.watch(watchThemedataUsecaseProvider),
      ref.watch(saveThemeModeUseCaseProvider),
    );
  },
);

/// ONBOARDING RELATED PROVIDERS
final onboardingRepositoryProvider = Provider(
  (ref) {
    return OnboardingRepositoryImpl();
  },
);

final getOnboardingPagesUsecaseProvider = Provider(
  (ref) {
    return GetOnboardingPagesUsecase(
      ref.watch(onboardingRepositoryProvider),
    );
  },
);

final getHasSeenOnboardingProvider = Provider((ref) {
  return WatchHasSeenOnboardingUsecase(
    ref.watch(localSettingsRepositoryProvider),
  );
});

final saveHasSeenOnboardingUseCaseProvider = Provider((ref) {
  return SaveHasSeenOnboardingUsecase(
    ref.watch(localSettingsRepositoryProvider),
  );
});

final onboardingBlocProvider = Provider(
  (ref) {
    return OnboardingBloc(
      ref.watch(saveHasSeenOnboardingUseCaseProvider),
      ref.watch(getOnboardingPagesUsecaseProvider),
    );
  },
);


// final onboardingProvider = Provider(
//   (ref) {},
// );