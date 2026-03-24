import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';

class SignInAppleUseCase {
  final IAuthRepository _repository;
  SignInAppleUseCase(this._repository);

  Future<Either<Failure, AuthUser>> call() => _repository.signInWithApple();
}
