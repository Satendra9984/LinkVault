import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/splash/domain/usecases/get_if_fist_timer.dart';
import 'package:link_vault/src/splash/domain/usecases/check_if_loggedin_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/set_onboarding_status_usecase.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetIfFistTimer _getIfFistTimer;
  final GetLoggedInStatus _getLoggedInStatus;
  final SetOnboardingStatusUsecase _setOnboardingStatusUsecase;

  SplashBloc({
    required GetIfFistTimer getIfFistTimer,
    required GetLoggedInStatus getLoggedInStatus,
    required SetOnboardingStatusUsecase setOnBoardingStatus,
  })  : _getLoggedInStatus = getLoggedInStatus,
        _getIfFistTimer = getIfFistTimer,
        _setOnboardingStatusUsecase = setOnBoardingStatus,
        super(SplashInitial()) {
    on<SplashEvent>(
      (event, emit) {},
    );
  }
}
