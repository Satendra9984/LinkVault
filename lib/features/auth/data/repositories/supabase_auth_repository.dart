import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../mappers/auth_user_mapper.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final sb.SupabaseClient _supabase;

  static const _premiumEntitlement = 'premium';
  static const _otpRedirectUri = 'com.vicharshala.linkvault://login-callback/';

  SupabaseAuthRepository(this._supabase);

  // ── Stream ───────────────────────────────────────────────────────────────

  @override
  Stream<AuthUser?> watchAuthState() {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      await _ensureProfileExists(
        user.id,
        user.userMetadata?['name']?.toString() ?? '',
        user.email ?? '',
      );
      final isPremium = await _checkPremium(user.id);
      return AuthUserMapper.fromSupabaseUser(user, isPremium: isPremium);
    });
  }

  @override
  AuthUser? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    unawaited(
      _ensureProfileExists(
        user.id,
        user.userMetadata?['name']?.toString() ?? '',
        user.email ?? '',
      ),
    );
    return AuthUserMapper.fromSupabaseUser(user);
  }

  // ── OTP Authentication ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> signInWithOTP({
    required String email,
    required AppOtpType type,
  }) async {
    try {
      AppLogger.d(
        'AuthRepo: Requesting OTP for $email (AppOtpType: $type, shouldCreateUser: true)',
      );
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        emailRedirectTo: _otpRedirectUri,
      );

      AppLogger.i('AuthRepo: OTP successfully sent to $email');
      return const Right(null);
    } on sb.AuthException catch (e) {
      AppLogger.w(
        'AuthRepo: Supabase AuthException during signInWithOtp - ${e.message} (code: ${e.statusCode})',
      );
      return Left(AuthFailure(
        _mapAuthError(e.message, type: type),
        code: e.statusCode ?? 'unknown',
      ));
    } catch (e, st) {
      AppLogger.e('AuthRepo: Unexpected error during signInWithOtp', e, st);
      return Left(UnexpectedFailure(
        'Failed to send OTP code',
        error: e,
        stackTrace: st,
      ));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> verifyOTP({
    required String email,
    required String otp,
    required AppOtpType type,
  }) async {
    try {
      AppLogger.d(
          'AuthRepo: Verifying OTP for $email. Length: ${otp.length}, using OtpType.email');
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: sb.OtpType.email,
      );

      final user = response.user;
      if (user == null) {
        AppLogger.w('AuthRepo: OTP verified but response.user is null');
        return Left(AuthFailure('Verification failed — no user returned',
            code: 'unknown'));
      }

      AppLogger.i('AuthRepo: OTP verified successfully for user ${user.id}');

      // Ensure the LinkVault profile table is populated after successful verification.
      await _ensureProfileExists(user.id, email, email);

      final isPremium = await _checkPremium(user.id);
      return Right(AuthUserMapper.fromSupabaseUser(user, isPremium: isPremium));
    } on sb.AuthException catch (e) {
      AppLogger.w(
          'AuthRepo: Supabase AuthException during verifyOTP - ${e.message} (code: ${e.statusCode})');
      return Left(AuthFailure(_mapAuthError(e.message),
          code: e.statusCode ?? 'unknown'));
    } catch (e, st) {
      AppLogger.e('AuthRepo: Unexpected error during verifyOTP', e, st);
      return Left(UnexpectedFailure('OTP verification failed',
          error: e, stackTrace: st));
    }
  }
  // ── Sign In (Google) ──────────────────────────────────────────────────────
  //
  // IMPORTANT — OAuth on mobile is asynchronous:
  //   signInWithOAuth() opens an external browser and returns immediately.
  //   The actual auth result arrives via a deep-link → onAuthStateChange fires.
  //   We must NOT read currentUser right after the call — it will always be null.
  //
  // Pattern:
  //   1. Launch the browser via signInWithOAuth().
  //   2. Return Right(placeholder) immediately so the UI loader stops.
  //   3. authStateProvider stream (watchAuthState) receives the real AuthUser
  //      when the deep-link callback fires, which triggers GoRouter to navigate.
  //
  // The AuthNotifier ignores the placeholder on successOnly — the router drives
  // navigation via _AuthStateListenable, not the notifier result.

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    try {
      final launched = await _supabase.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: 'com.vicharshala.linkvault://login-callback/',
      );
      if (!launched) {
        return Left(AuthFailure('Could not launch Google sign-in',
            code: 'launch_failed'));
      }
      // Return a pending sentinel. The router navigates when onAuthStateChange fires.
      return Right(_pendingOAuthUser());
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message),
          code: e.statusCode ?? 'unknown'));
    } catch (e, st) {
      return Left(
          UnexpectedFailure('Google sign-in failed', error: e, stackTrace: st));
    }
  }

  // ── Sign In (Apple) ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AuthUser>> signInWithApple() async {
    try {
      final launched = await _supabase.auth.signInWithOAuth(
        sb.OAuthProvider.apple,
        redirectTo: 'com.vicharshala.linkvault://login-callback/',
      );
      if (!launched) {
        return Left(AuthFailure('Could not launch Apple sign-in',
            code: 'launch_failed'));
      }
      return Right(_pendingOAuthUser());
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message),
          code: e.statusCode ?? 'unknown'));
    } catch (e, st) {
      return Left(
          UnexpectedFailure('Apple sign-in failed', error: e, stackTrace: st));
    }
  }

  // ── Sign Out & Delete Account ─────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(null);
    } catch (e, st) {
      return Left(
          UnexpectedFailure('Sign out failed', error: e, stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure('Cannot delete account: not signed in',
            code: 'no_session'));
      }

      AppLogger.i('AuthRepo: Initiating account deletion for user: ${user.id}');

      // Call the SECURITY DEFINER postgres function to delete the auth.users record natively.
      // This cascades and destroys user_profiles, collections, items, and friends automatically.
      await _supabase.rpc('lv_delete_user');

      AppLogger.i(
          'AuthRepo: RPC lv_delete_user completed. Wiping local auth session...');
      await _supabase.auth.signOut();

      return const Right(null);
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message),
          code: e.statusCode ?? 'unknown'));
    } catch (e, st) {
      return Left(UnexpectedFailure('Failed to delete account',
          error: e, stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLinkVaultData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure('Cannot delete LinkVault data: not signed in',
            code: 'no_session'));
      }

      AppLogger.i(
          'AuthRepo: Initiating LinkVault-only data deletion for user: ${user.id}');

      await _supabase.rpc('lv_delete_linkvault_data');
      await _cleanupLinkVaultStorage();

      AppLogger.i(
          'AuthRepo: LinkVault data cleanup completed. Wiping local auth session...');
      await _supabase.auth.signOut();

      return const Right(null);
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message),
          code: e.statusCode ?? 'unknown'));
    } catch (e, st) {
      return Left(UnexpectedFailure('Failed to delete LinkVault data',
          error: e, stackTrace: st));
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  /// A sentinel AuthUser returned while OAuth browser is open.
  /// Has no supabaseId — isGuest == true, isPremium == false.
  /// The real user arrives via watchAuthState() → onAuthStateChange deep-link.
  AuthUser _pendingOAuthUser() => const AuthUser();

  Future<bool> _checkPremium(String userId) async {
    try {
      await Purchases.logIn(userId);
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_premiumEntitlement);
    } catch (_) {
      return false;
    }
  }

  Future<void> _cleanupLinkVaultStorage() async {
    try {
      final response = await _supabase.functions.invoke('lv-delete-storage');
      final payload = response.data;
      AppLogger.i('AuthRepo: lv-delete-storage invoke result: $payload');
    } catch (e, st) {
      // Storage deletion is best-effort; DB cleanup already completed.
      AppLogger.w('AuthRepo: lv-delete-storage invoke failed: $e');
      AppLogger.e('AuthRepo: lv-delete-storage invoke failed trace', e, st);
    }
  }

  Future<void> _ensureProfileExists(
      String userId, String name, String email) async {
    try {
      AppLogger.d('profile_bootstrap_attempt user=$userId');
      final existing = await _supabase
          .from('lv_user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (existing == null) {
        final displayName = name.isEmpty ? email.split('@').first : name;
        try {
          await _supabase.from('lv_user_profiles').insert({
            'id': userId,
            'display_name': displayName,
          });
        } on sb.PostgrestException catch (e) {
          // EC-02: another concurrent path may create the row first.
          if (e.code == '23505') {
            AppLogger.d(
              'profile_bootstrap_success user=$userId created=false duplicate_race=true',
            );
            return;
          }
          rethrow;
        }
        AppLogger.i('profile_bootstrap_success user=$userId created=true');
      } else {
        AppLogger.d('profile_bootstrap_success user=$userId created=false');
      }
    } catch (e, st) {
      AppLogger.w('profile_bootstrap_failure user=$userId error=$e');
      AppLogger.e('profile_bootstrap_failure_trace', e, st);
    }
  }

  String _mapAuthError(String message, {AppOtpType? type}) {
    final lower = message.toLowerCase();
    if (message.contains('Invalid login credentials')) {
      return 'Authentication failed. Please try requesting a new code.';
    }
    if (message.contains('User already registered') ||
        message.contains('User already exists')) {
      return 'An account already exists with this email';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please confirm your email before signing in';
    }
    if (message.contains('Signups not allowed for otp') ||
        message.contains('Signups not allowed')) {
      if (type == AppOtpType.signup) {
        return 'Signups are currently disabled. Please enable "Allow new users to sign up" in your Supabase Auth Providers settings.';
      }
      return 'No account found for this email. Please sign up first.';
    }
    if (lower.contains('expired') || lower.contains('invalid')) {
      return 'The code you entered is incorrect or has expired.';
    }
    if (lower.contains('too many requests') ||
        lower.contains('rate limit') ||
        lower.contains('retry after')) {
      return 'Too many attempts. Please wait a minute and try again.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Network issue detected. Check your connection and try again.';
    }
    if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters';
    }
    return message;
  }
}
