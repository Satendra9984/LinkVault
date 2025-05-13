import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_is_loggedin_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_settings_usecase.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetIsLoggedinUsecase _getIsLoggedinUsecase;
  final GetSettingsUsecase _getSettingsUsecase;

  SplashBloc(
    this._getIsLoggedinUsecase,
    this._getSettingsUsecase,
  ) : super(
          SplashInitial(),
        ) {
    on<SplashEvent>(_check);
  }

  Future<void> _check(SplashEvent event, Emitter<SplashState> emit) async {
    late Either<Failure, LocalAppSettings> localAppSettings;
    late Either<Failure, bool> isUserLoggedIn;

    emit(SplashLoading());

    await Future.wait([
      Future(
        () async => localAppSettings = await _getSettingsUsecase.call(),
      ),
      Future(
        () async => isUserLoggedIn = await _getIsLoggedinUsecase.call(),
      ),
    ]);

    localAppSettings.fold(
      (failed) {
        emit(SplashError(failed.errorMessage));
      },
      (localAppSettings) {
        isUserLoggedIn.fold(
          (failed) => emit(
            SplashError(failed.errorMessage),
          ),
          (loggedIn) {
            if (loggedIn == true || localAppSettings.hasSeenOnboarding) {
              emit(SplashNavigateToHome());
            } else if (localAppSettings.hasSeenOnboarding == false) {
              emit(SplashNavigateToOnboarding());
            } else {
              emit(SplashNavigateToLogin());
            }
          },
        );
      },
    );
  }
}
