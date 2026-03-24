import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/usecases/sign_in_apple_usecase.dart';
import '../../domain/usecases/sign_in_google_usecase.dart';
import '../../domain/usecases/sign_in_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_providers.dart';

// ── State ──────────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool otpSent;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.otpSent = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? otpSent,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        otpSent: otpSent ?? this.otpSent,
      );
}

// ── Provider ───────────────────────────────────────────────────────────────

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

// ── Notifier ───────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  // ── Passwordless OTP ───────────────────────────────────────────────────

  Future<void> signInWithOTP({
    required String email,
    required AppOtpType type,
  }) async {
    AppLogger.d(
        'AuthNotifier: signInWithOTP called for $email with type $type');
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await SignInOtpUseCase(ref.read(authRepositoryProvider))
        .call(SignInOtpParams(email: email, type: type));
    result.fold(
      (failure) {
        AppLogger.w('AuthNotifier: signInWithOTP failed - ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        AppLogger.i('AuthNotifier: signInWithOTP succeeded');
        state = state.copyWith(
          isLoading: false,
          otpSent: true,
        );
      },
    );
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
    required AppOtpType type,
  }) async {
    AppLogger.d('AuthNotifier: verifyOTP called for $email (type $type)');
    state = state.copyWith(isLoading: true, clearError: true);
    final result =
        await VerifyOtpUseCase(ref.read(authRepositoryProvider)).call(
      VerifyOtpParams(email: email, otp: otp, type: type),
    );
    result.fold(
      (failure) {
        AppLogger.w('AuthNotifier: verifyOTP failed - ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) async {
        AppLogger.i('AuthNotifier: verifyOTP succeeded');
        await ref
            .read(appSettingsRepositoryProvider)
            .setGuestMode(value: false);
        state = state.copyWith(isLoading: false);
      },
    );
  }

  // ── Sign In (Google) ───────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result =
        await SignInGoogleUseCase(ref.read(authRepositoryProvider)).call();
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) async {
        await ref
            .read(appSettingsRepositoryProvider)
            .setGuestMode(value: false);
        state = state.copyWith(isLoading: false);
      },
    );
  }

  // ── Sign In (Apple) ────────────────────────────────────────────────────

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result =
        await SignInAppleUseCase(ref.read(authRepositoryProvider)).call();
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) async {
        await ref
            .read(appSettingsRepositoryProvider)
            .setGuestMode(value: false);
        state = state.copyWith(isLoading: false);
      },
    );
  }

  // ── Sign Out ───────────────────────────────────────────────────────────

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    // Clear local session data (guest mode, premium cache) on sign-out
    await ref.read(appSettingsRepositoryProvider).clearSessionData();
    final result =
        await SignOutUseCase(ref.read(authRepositoryProvider)).call();
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state = state.copyWith(isLoading: false),
    );
  }

  // ── Continue as Guest ──────────────────────────────────────────────────

  Future<void> continueAsGuest() async {
    await ref.read(appSettingsRepositoryProvider).setGuestMode(value: true);
    // authStateProvider will emit null (no Supabase session),
    // but isGuestMode=true in objectbox tells GoRouter to allow home access
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void clearError() => state = state.copyWith(clearError: true);
}
