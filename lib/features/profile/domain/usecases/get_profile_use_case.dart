import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/i_profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(String userId) {
    return repository.getProfile(userId);
  }
}
