import '../../domain/entities/user_profile.dart';

class UserProfileMapper {
  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      displayName: (json['display_name'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      activitySharingEnabled: json['activity_sharing_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(UserProfile profile) {
    return {
      'id': profile.userId,
      'display_name': profile.displayName,
      'avatar_url': profile.avatarUrl,
      'created_at': profile.createdAt.toIso8601String(),
    };
  }
}
