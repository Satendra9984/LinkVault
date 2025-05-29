import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final String? profilePictureUrl;
  final String? bio;
  final int usageCredits;
  final bool isPremium;
  final DateTime premiumExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> settings;

  const UserProfile({
    required this.id,
    required this.premiumExpiresAt,
    this.displayName,
    this.profilePictureUrl,
    this.bio,
    this.usageCredits = 0,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActiveAt,
    this.settings = const {},
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        profilePictureUrl,
        bio,
        usageCredits,
        isPremium,
        premiumExpiresAt,
        createdAt,
        updatedAt,
        lastActiveAt,
        settings,
      ];

  UserProfile copyWith({
    String? displayName,
    String? profilePictureUrl,
    String? bio,
    int? usageCredits,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      id: this.id,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      usageCredits: usageCredits ?? this.usageCredits,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      settings: settings ?? this.settings,
    );
  }
}
