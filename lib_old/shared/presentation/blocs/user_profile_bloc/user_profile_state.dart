part of 'user_profile_bloc.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();
  
  @override
  List<Object> get props => [];
}

final class UserProfileInitial extends UserProfileState {}


class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile userProfile;
  
  const UserProfileLoaded(this.userProfile);
  
  @override
  List<Object> get props => [userProfile];
}

class UserProfileError extends UserProfileState {
  final String message;
  
  const UserProfileError(this.message);
  
  @override
  List<Object> get props => [message];
}

class UserProfileUpdating extends UserProfileState {}

class UserProfileUpdateSuccess extends UserProfileState {
  final UserProfile userProfile;
  
  const UserProfileUpdateSuccess(this.userProfile);
  
  @override
  List<Object> get props => [userProfile];
}

class UserProfileUpdateError extends UserProfileState {
  final String message;
  
  const UserProfileUpdateError(this.message);
  
  @override
  List<Object> get props => [message];
}
