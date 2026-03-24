import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

enum AppOtpType {
  signup,
  magiclink,
}

abstract class IAuthRepository {
  /// Hot stream — emits [AuthUser] when session exists, null when signed out.
  /// Drives [authStateProvider] and GoRouter redirect guard.
  Stream<AuthUser?> watchAuthState();

  /// Synchronous read used by GoRouter redirect (no async allowed there).
  AuthUser? getCurrentUser();

  Future<Either<Failure, void>> signInWithOTP({
    required String email,
    required AppOtpType type,
  });

  Future<Either<Failure, AuthUser>> verifyOTP({
    required String email,
    required String otp,
    required AppOtpType type,
  });

  Future<Either<Failure, AuthUser>> signInWithGoogle();

  Future<Either<Failure, AuthUser>> signInWithApple();

  Future<Either<Failure, void>> signOut();

  /// Natively deletes the user's `auth.users` record via an RPC.
  /// The `ON DELETE CASCADE` rule will wipe `user_profiles`, `collections`, etc.
  Future<Either<Failure, void>> deleteAccount();
}
