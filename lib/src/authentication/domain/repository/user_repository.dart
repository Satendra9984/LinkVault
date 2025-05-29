import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import '../entities/user_profile.dart';

abstract class UserRepository {
  /// Get current user profile
  Future<Either<Failure, UserProfile>> getUserProfile();
  
  /// Update user profile
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  
  /// Create user profile (after signup)
  Future<Either<Failure, UserProfile>> createUserProfile(String userId, {
    String? displayName,
    String? profilePictureUrl,
    String? bio,
    Map<String, dynamic>? settings,
  });

  /// Stream user profile changes
  Stream<UserProfile?> userProfileStream();
}
