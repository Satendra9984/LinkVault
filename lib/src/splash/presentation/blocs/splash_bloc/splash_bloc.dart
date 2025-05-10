import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final LocalAppSettingsRepository _splashRepository;

  SplashBloc(LocalAppSettingsRepository splashRepo)
      : _splashRepository = splashRepo,
        super(SplashInitial(null)) {
    on<SplashEvent>(_check);
  }

  Future<void> _check(SplashEvent event, Emitter<SplashState> emit) async {
    late Either<Failure, LocalAppSettings> localAppSettings;
    late Either<Failure, bool> isUserLoggedIn;

    await Future.wait([
      Future(
        () async => localAppSettings = await _splashRepository.getAppSettings(),
      ),
      Future(
        () async => isUserLoggedIn = await _splashRepository.getIsLoggedIn(),
      ),
    ]);

    localAppSettings.fold(
      (failed) {
        emit(
          SplashError(failed.errorMessage, null),
        );
      },
      (localAppSettings) {
        isUserLoggedIn.fold(
          (failed) {
            emit(
              SplashError(failed.errorMessage, null),
            );
          },
          (loginstatus) {
            Logger.printLog(
              '[loginstatus] : ${loginstatus}, localappsettings: ${localAppSettings.hasSeenOnboarding}, ${localAppSettings.themeMode.value}',
            );
            if (loginstatus == true) {
              emit(
                SplashNavigateToHome(localAppSettings),
              );
              return;
            }

            if (localAppSettings.hasSeenOnboarding == false) {
              emit(
                SplashNavigateToOnboarding(localAppSettings),
              );
            } else {
              emit(
                SplashNavigateToHome(localAppSettings),
              );
            }
          },
        );
      },
    );
  }

  // final GetIfFistTimer _getIfFistTimer;
  // final GetLoggedInStatus _getLoggedInStatus;
  // final SetOnboardingStatusUsecase _setOnboardingStatusUsecase;

  // SplashBloc({
  //   required GetIfFistTimer getIfFistTimer,
  //   required GetLoggedInStatus getLoggedInStatus,
  //   required SetOnboardingStatusUsecase setOnBoardingStatus,
  // })  : _getLoggedInStatus = getLoggedInStatus,
  //       _getIfFistTimer = getIfFistTimer,
  //       _setOnboardingStatusUsecase = setOnBoardingStatus,
  //       super(SplashInitial()) {
  //   on<SplashEvent>(
  //     (event, emit) {},
  //   );
  // }
}
