import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class GetSettingsUsecase {
  final LocalAppSettingsRepository repository;

  GetSettingsUsecase(this.repository);

  Future<Either<Failure, LocalAppSettings>> call() => repository.getAppSettings();
}
