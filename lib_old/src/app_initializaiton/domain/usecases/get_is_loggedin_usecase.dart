// features/splash/domain/usecases/get_initial_status.dart

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';

import '../repositories/local_app_settings_repository.dart';

class GetIsLoggedinUsecase {
  final LocalAppSettingsRepository repo;
  GetIsLoggedinUsecase(this.repo);

  Future<Either<Failure, bool>> call() async => repo.getIsLoggedIn();
}
