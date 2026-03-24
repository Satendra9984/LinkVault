import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final bool activitySharingEnabled;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    this.username = '',
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.activitySharingEnabled = true,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    bool? activitySharingEnabled,
  }) {
    return UserProfile(
      userId: userId,
      username: username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      activitySharingEnabled:
          activitySharingEnabled ?? this.activitySharingEnabled,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        displayName,
        avatarUrl,
        bio,
        activitySharingEnabled,
        createdAt,
      ];
}
