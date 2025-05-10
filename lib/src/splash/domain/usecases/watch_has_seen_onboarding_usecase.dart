import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class WatchHasSeenOnboardingUsecase {
  final LocalAppSettingsRepository repository;

  WatchHasSeenOnboardingUsecase(this.repository);

  Stream<Either<Failure, bool>> call() => repository.watchHasSeenOnboarding();
}
