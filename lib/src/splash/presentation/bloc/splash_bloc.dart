import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';
import 'package:link_vault/src/splash/domain/usecases/get_if_fist_timer.dart';
import 'package:link_vault/src/splash/domain/usecases/check_if_loggedin_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/set_onboarding_status_usecase.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashRepository _splashRepository;

  SplashBloc(SplashRepository splashRepo)
      : _splashRepository = splashRepo,
        super(SplashInitial()) {
    on<SplashEvent>(
      _check,
    );
  }

  void _check(SplashEvent event, Emitter<SplashState> emit) async {
    await _splashRepository.getAppSettings().then(
      (res) {
        res.fold(
          (failed) {
            emit(SplashError(failed.errorMessage));
          },
          (localAppSettings) {
            // TODO: CHECK FOR LOGIN STATUS FIRST

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
