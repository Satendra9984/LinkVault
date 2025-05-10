import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class SaveHasSeenOnboardingUsecase {
  final LocalAppSettingsRepository _splashRepository;

  SaveHasSeenOnboardingUsecase(this._splashRepository);

  Future<Either<Failure, void>> call(bool onBoardingStatus) =>
      _splashRepository.setHasSeenOnboarding(onBoardingStatus);
}
