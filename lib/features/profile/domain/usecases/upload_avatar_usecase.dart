import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/features/profile/domain/repositories/i_profile_repository.dart';

class UploadAvatarParams {
  final String userId;
  final File avatarFile;

  const UploadAvatarParams({
    required this.userId,
    required this.avatarFile,
  });
}

class UploadAvatarUseCase {
  final IProfileRepository _repository;

  UploadAvatarUseCase(this._repository);

  Future<Either<Failure, String>> call(UploadAvatarParams params) async {
    if (!params.avatarFile.existsSync()) {
      return const Left(UnexpectedFailure('Avatar file does not exist.'));
    }

    // Optional: add file size validation here (e.g., max 5MB)
    final sizeInBytes = params.avatarFile.lengthSync();
    if (sizeInBytes > 5 * 1024 * 1024) {
      return const Left(
          UnexpectedFailure('Image is too large. Maximum size is 5MB.'));
    }

    return _repository.uploadAvatar(
      userId: params.userId,
      avatarFile: params.avatarFile,
    );
  }
}
