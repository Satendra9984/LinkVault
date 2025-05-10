part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  SplashInitial();
}

class SplashLoading extends SplashState {
  SplashLoading();
}

class SplashNavigateToOnboarding extends SplashState {
  SplashNavigateToOnboarding();
}

class SplashNavigateToHome extends SplashState {
  SplashNavigateToHome();
}

class SplashNavigateToLogin extends SplashState {
  SplashNavigateToLogin();
}

class SplashError extends SplashState {
  SplashError(
    String message,
  );
}
