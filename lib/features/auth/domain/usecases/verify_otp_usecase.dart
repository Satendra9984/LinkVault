import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';

class VerifyOtpParams {
  final String email;
  final String otp;
  final AppOtpType type;

  const VerifyOtpParams({
    required this.email,
    required this.otp,
    required this.type,
  });
}

class VerifyOtpUseCase {
  final IAuthRepository _repository;
  VerifyOtpUseCase(this._repository);

  Future<Either<Failure, AuthUser>> call(VerifyOtpParams params) =>
      _repository.verifyOTP(
        email: params.email.trim(),
        otp: params.otp.trim(),
        type: params.type,
      );
}
