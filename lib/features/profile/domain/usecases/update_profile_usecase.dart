import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/features/profile/domain/entities/user_profile.dart';
import 'package:link_vault/features/profile/domain/repositories/i_profile_repository.dart';

class UpdateProfileParams {
  final String userId;
  final String? displayName;
  final String? bio;
  final bool? activitySharingEnabled;

  const UpdateProfileParams({
    required this.userId,
    this.displayName,
    this.bio,
    this.activitySharingEnabled,
  });
}

class UpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) async {
    // Optional basic validation before passing to repository
    if (params.displayName != null && params.displayName!.trim().isEmpty) {
      return const Left(UnexpectedFailure('Display name cannot be empty.'));
    }

    if (params.bio != null && params.bio!.length > 160) {
      return const Left(UnexpectedFailure('Bio cannot exceed 160 characters.'));
    }

    return _repository.updateProfile(
      userId: params.userId,
      displayName: params.displayName?.trim(),
      bio: params.bio?.trim(),
      activitySharingEnabled: params.activitySharingEnabled,
    );
  }
}
