import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class SignInOtpParams {
  final String email;
  final AppOtpType type;

  const SignInOtpParams({
    required this.email,
    required this.type,
  });
}

class SignInOtpUseCase {
  final IAuthRepository _repository;
  SignInOtpUseCase(this._repository);

  Future<Either<Failure, void>> call(SignInOtpParams params) =>
      _repository.signInWithOTP(
        email: params.email.trim(),
        type: params.type,
      );
}
