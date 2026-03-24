import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/i_profile_repository.dart';

class UpdateProfileUseCase {
  final IProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required String userId,
    String? displayName,
    String? bio,
    bool? activitySharingEnabled,
  }) {
    return repository.updateProfile(
      userId: userId,
      displayName: displayName,
      bio: bio,
      activitySharingEnabled: activitySharingEnabled,
    );
  }
}
