import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/app_initializaiton/domain/repositories/local_app_settings_repository.dart';

class GetSettingsUsecase {
  final LocalAppSettingsRepository repository;

  GetSettingsUsecase(this.repository);

  Future<Either<Failure, LocalAppSettings>> call() => repository.getAppSettings();
}
