part of 'forget_password_cubit.dart';

class ForgetPasswordState extends Equatable {
  final ForgetPasswordStates forgetPasswordStates;

  final String email;

  const ForgetPasswordState({
    required this.forgetPasswordStates,
    required this.email,
  });

  ForgetPasswordState copyWith({
    ForgetPasswordStates? forgetPasswordStates,
    String? email,
  }) {
    return ForgetPasswordState(
      forgetPasswordStates: forgetPasswordStates ?? this.forgetPasswordStates,
      email: email ?? this.email,
    );
  }

  @override
  List<Object> get props => [forgetPasswordStates, email];
}
