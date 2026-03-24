import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class SignOutUseCase {
  final IAuthRepository _repository;
  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.signOut();
}
