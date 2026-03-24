import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/auth_user.dart';

class AuthUserMapper {
  static AuthUser fromSupabaseUser(sb.User user, {bool isPremium = false}) {
    return AuthUser(
      supabaseId: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String? ?? user.email,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      isPremium: isPremium,
    );
  }
}
