import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final bool activitySharingEnabled;
  final DateTime createdAt;

  /// Server flag: this account may not receive the 3-day install trial again.
  final bool installTrialConsumed;

  const UserProfile({
    required this.userId,
    this.username = '',
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.activitySharingEnabled = true,
    required this.createdAt,
    this.installTrialConsumed = false,
  });

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    bool? activitySharingEnabled,
    bool? installTrialConsumed,
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
      installTrialConsumed: installTrialConsumed ?? this.installTrialConsumed,
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
        installTrialConsumed,
      ];
}
