import 'package:equatable/equatable.dart';

/// Represents the currently authenticated user (or a guest session).
///
/// When [supabaseId] is null, the user is in guest mode — local objectbox storage
/// only, no account, subject to DayPass ad gate.
class AuthUser extends Equatable {
  final String? supabaseId;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final bool isPremium;

  const AuthUser({
    this.supabaseId,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.isPremium = false,
  });

  /// No Supabase account — guest session.
  bool get isGuest => supabaseId == null;

  /// Has a Supabase account (free or premium).
  bool get isAuthenticated => supabaseId != null;

  /// Conceptual hint only; the app uses [collectionsRepositoryProvider] /
  /// [itemsRepositoryProvider] (guest = local, signed-in + online = cloud per ADR-0002).
  bool get useCloudStorage => isAuthenticated;

  AuthUser copyWith({
    String? displayName,
    String? avatarUrl,
    bool? isPremium,
  }) =>
      AuthUser(
        supabaseId: supabaseId,
        email: email,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isPremium: isPremium ?? this.isPremium,
      );

  @override
  List<Object?> get props => [supabaseId, email, isPremium];
}
