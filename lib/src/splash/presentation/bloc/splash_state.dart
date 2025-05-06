part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {
  const SplashNavigateToOnboarding(
    this.localAppSettings,
  );

  final LocalAppSettings localAppSettings;
}

class SplashNavigateToHome extends SplashState {
  const SplashNavigateToHome(
    this.localAppSettings,
  );

  final LocalAppSettings localAppSettings;
}

class SplashNavigateToLogin extends SplashState {
  const SplashNavigateToLogin(
    this.localAppSettings,
  );

  final LocalAppSettings localAppSettings;
}

class SplashError extends SplashState {
  SplashError(String message);
}
