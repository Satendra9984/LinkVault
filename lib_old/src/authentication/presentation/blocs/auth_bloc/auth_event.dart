part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}
class AppStarted extends AuthEvent {}

class UserLoggedIn extends AuthEvent {
  final String userId;
  
  const UserLoggedIn(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class UserSignedUp extends AuthEvent {
  final String userId;
  
  const UserSignedUp(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class UserLoggedOut extends AuthEvent {}

class CheckAuth extends AuthEvent {}
