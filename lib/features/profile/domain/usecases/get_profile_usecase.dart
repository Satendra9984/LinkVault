import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/features/profile/domain/entities/user_profile.dart';
import 'package:link_vault/features/profile/domain/repositories/i_profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, UserProfile>> call(String userId) async {
    return _repository.getProfile(userId);
  }
}
