part of 'email_verification_bloc.dart';

sealed class EmailVerificationEvent extends Equatable {
  const EmailVerificationEvent();

  @override
  List<Object> get props => [];
}

class ResendVerificationEmail extends EmailVerificationEvent {
  final String email;

  ResendVerificationEmail(this.email);
}

class VerifyEmailToken extends EmailVerificationEvent {
  final String authCode;

  VerifyEmailToken({
    required this.authCode,
  });
}
