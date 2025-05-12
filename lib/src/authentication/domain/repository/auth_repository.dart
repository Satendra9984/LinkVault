import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/authentication/domain/entities/user_profile.dart';

// lib/domain/repositories/auth_repository.dart


abstract class AuthRepository {
  /// Stream of current auth state
  Stream<bool> get authStateChanges;
  
  /// Get current user ID if authenticated
  Future<String?> getCurrentUserId();

  /// Sign in with email and password
  Future<Either<Failure, UserProfile>> signInWithEmailPassword(String email, String password);
  
  /// Sign up with email and password
  Future<Either<Failure, UserProfile>> signUpWithEmailPassword(String email, String password);
  
  /// Sign out
  Future<Either<Failure, void>> signOut();
  
  /// Password reset
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Check if user is signed in
  Future<bool> isSignedIn();
}
