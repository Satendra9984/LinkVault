// features/splash/domain/usecases/get_initial_status.dart

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';

import '../repositories/local_app_settings_repository.dart';

class WatchIsLoggedinUsecase {
  final LocalAppSettingsRepository repo;
  WatchIsLoggedinUsecase(this.repo);

  Future<Either<Failure, bool>> call() async => repo.getIsLoggedIn();
}
