import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/app_initializaiton/domain/repositories/local_app_settings_repository.dart';

class WatchHasSeenOnboardingUsecase {
  final LocalAppSettingsRepository repository;

  WatchHasSeenOnboardingUsecase(this.repository);

  Stream<Either<Failure, bool>> call() => repository.watchHasSeenOnboarding();
}
