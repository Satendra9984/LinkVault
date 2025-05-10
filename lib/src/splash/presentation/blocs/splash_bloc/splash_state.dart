part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  SplashState(
    this.localAppSettings,
  );

  final LocalAppSettings? localAppSettings;

  @override
  List<Object?> get props => [localAppSettings];
}

class SplashInitial extends SplashState {
  SplashInitial(super.localAppSettings);
}

class SplashLoading extends SplashState {
  SplashLoading(super.localAppSettings);
}

class SplashNavigateToOnboarding extends SplashState {
  SplashNavigateToOnboarding(
    super.localAppSettings,
  );
}

class SplashNavigateToHome extends SplashState {
  SplashNavigateToHome(
    super.localAppSettings,
  );
}

class SplashNavigateToLogin extends SplashState {
  SplashNavigateToLogin(
    super.localAppSettings,
  );
}

class SplashError extends SplashState {
  SplashError(
    String message,
    super.localAppSettings,
  );
}
