part of 'authentication_cubit.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStates authenticationStates;
  final Failure? authenticationFailure;

  const AuthenticationState({
    required this.authenticationStates,
    this.authenticationFailure,
  });

  AuthenticationState copyWith({
    AuthenticationStates? authenticationStates,
    OnBoardingStates? onBoardingStates,
    Failure? authenticationFailure,
  }) {
    return AuthenticationState(
      authenticationStates: authenticationStates ?? this.authenticationStates,
      authenticationFailure:
          authenticationFailure ?? this.authenticationFailure,
    );
  }

  @override
  List<Object?> get props => [
        authenticationStates,
        authenticationFailure,
      ];
}
