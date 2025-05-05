// features/splash/domain/usecases/get_initial_status.dart

import '../repositories/splash_repository.dart';

class GetLoggedInStatus {
  final SplashRepository repo;
  GetLoggedInStatus(this.repo);

  Future<bool> call() async => await repo.getIfLoggedIn();
}
