part of 'forget_password_cubit.dart';

class ForgetPasswordState extends Equatable {
  const ForgetPasswordState({
    required this.forgetPasswordStates,
    required this.email,
    this.forgetPasswordFailure,
  });
  final ForgetPasswordStates forgetPasswordStates;
  final Failure? forgetPasswordFailure;

  final String email;

  ForgetPasswordState copyWith({
    ForgetPasswordStates? forgetPasswordStates,
    String? email,
    Failure? forgetPasswordFailure,
  }) {
    return ForgetPasswordState(
      forgetPasswordStates: forgetPasswordStates ?? this.forgetPasswordStates,
      email: email ?? this.email,
      forgetPasswordFailure:
          forgetPasswordFailure ?? this.forgetPasswordFailure,
    );
  }

  @override
  List<Object?> get props => [
        forgetPasswordStates,
        email,
        forgetPasswordFailure,
      ];
}
