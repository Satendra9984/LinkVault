part of 'user_profile_bloc.dart';


sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final UserProfile userProfile;
  
  const UpdateUserProfile(this.userProfile);
  
  @override
  List<Object?> get props => [userProfile];
}

class UpdateUserDisplayName extends UserProfileEvent {
  final String displayName;
  
  const UpdateUserDisplayName(this.displayName);
  
  @override
  List<Object?> get props => [displayName];
}

class UpdateUserBio extends UserProfileEvent {
  final String bio;
  
  const UpdateUserBio(this.bio);
  
  @override
  List<Object?> get props => [bio];
}

class UpdateUserProfilePicture extends UserProfileEvent {
  final String profilePictureUrl;
  
  const UpdateUserProfilePicture(this.profilePictureUrl);
  
  @override
  List<Object?> get props => [profilePictureUrl];
}

class UpdateUserSettings extends UserProfileEvent {
  final Map<String, dynamic> settings;
  
  const UpdateUserSettings(this.settings);
  
  @override
  List<Object?> get props => [settings];
}
