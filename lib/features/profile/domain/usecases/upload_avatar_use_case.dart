import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_profile_repository.dart';

class UploadAvatarUseCase {
  final IProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required File avatarFile,
  }) {
    return repository.uploadAvatar(
      userId: userId,
      avatarFile: avatarFile,
    );
  }
}
