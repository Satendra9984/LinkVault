import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';

class SignInGoogleUseCase {
  final IAuthRepository _repository;
  SignInGoogleUseCase(this._repository);

  Future<Either<Failure, AuthUser>> call() => _repository.signInWithGoogle();
}
