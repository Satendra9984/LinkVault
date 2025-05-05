import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class SetOnboardingStatusUsecase {
  final SplashRepository _splashRepository;

  SetOnboardingStatusUsecase(this._splashRepository);

  Future<void> call(bool onBoardingStatus) async {
    await _splashRepository.setOnBoardingStatus(onBoardingStatus);
  }
}
