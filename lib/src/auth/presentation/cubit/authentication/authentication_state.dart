part of 'authentication_cubit.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStates authenticationStates;
  // final OnBoardingStates onBoardingStates;
  const AuthenticationState({
    required this.authenticationStates,
    // required this.onBoardingStates,
  });

  AuthenticationState copyWith({
    AuthenticationStates? authenticationStates,
    OnBoardingStates? onBoardingStates,
  }) {
    return AuthenticationState(
      authenticationStates: authenticationStates ?? this.authenticationStates,
      // onBoardingStates: onBoardingStates ?? this.onBoardingStates,
    );
  }

  @override
  List<Object> get props => [
        authenticationStates,
        // onBoardingStates,
      ];
}
