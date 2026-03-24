import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class IProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile(String userId);
  Future<Either<Failure, void>> ensureProfileExists({
    required String userId,
    required String email,
    String? displayName,
  });

  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    bool? activitySharingEnabled,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File avatarFile,
  });
}
