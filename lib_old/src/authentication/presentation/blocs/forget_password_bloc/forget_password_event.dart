part of 'forget_password_bloc.dart';

sealed class ForgetPasswordEvent extends Equatable {
  const ForgetPasswordEvent();

  @override
  List<Object> get props => [];
}

class SendResetEmail extends ForgetPasswordEvent {
  final String email;
  SendResetEmail(this.email);
}