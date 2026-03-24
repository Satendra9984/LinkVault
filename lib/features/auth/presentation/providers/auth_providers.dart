import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../monetization/presentation/providers/premium_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository(sb.Supabase.instance.client);
});

// ── Central Auth Stream ───────────────────────────────────────────────────────

/// THE source of truth for auth state across the entire app.
/// GoRouter watches this to trigger redirect logic on sign-in / sign-out.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

// ── Convenience Providers ─────────────────────────────────────────────────────

/// Current user value, or null if loading / signed out / guest.
final currentUserProvider =
    Provider<AuthUser?>((ref) => ref.watch(authStateProvider).valueOrNull);

/// True only if the current user has an active "premium" entitlement.
final isPremiumProvider = Provider<bool>((ref) {
  final dbPremium = ref.watch(currentUserProvider)?.isPremium ?? false;
  final rcPremium = ref.watch(revenueCatPremiumProvider).valueOrNull ?? false;
  return dbPremium || rcPremium;
});

/// True if no Supabase session (guest or unauthenticated).
final isGuestProvider =
    Provider<bool>((ref) => ref.watch(currentUserProvider)?.isGuest ?? true);
