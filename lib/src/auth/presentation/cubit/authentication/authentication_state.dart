part of 'authentication_cubit.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStates authenticationStates;
  final Failure? authenticationFailure;
  final GlobalUser? globalUser;

  const AuthenticationState({
    required this.authenticationStates,
    this.authenticationFailure,
    this.globalUser,
  });

  AuthenticationState copyWith({
    AuthenticationStates? authenticationStates,
    OnBoardingStates? onBoardingStates,
    Failure? authenticationFailure,
    GlobalUser? globalUser, 
  }) {
    return AuthenticationState(
      authenticationStates: authenticationStates ?? this.authenticationStates,
      authenticationFailure:
          authenticationFailure ?? this.authenticationFailure,
       globalUser: globalUser ?? this.globalUser,   
    );
  }

  @override
  List<Object?> get props => [
        authenticationStates,
        authenticationFailure,
        globalUser,
      ];
}
