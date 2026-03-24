import '../../../../core/domain/repositories/user_repository.dart';

class CheckFirstLaunchUseCase {
  final UserRepository _repository;

  CheckFirstLaunchUseCase(this._repository);

  Future<bool> call() {
    return _repository.isFirstLaunch();
  }
}
