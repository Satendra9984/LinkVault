import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignupWithCredentials extends SignupEvent {
  final String email;
  final String password;
  final String displayName;

  const SignupWithCredentials({
    required this.email,
    required this.password,
    this.displayName = '',
  });

  @override
  List<Object?> get props => [email, password, displayName];
}