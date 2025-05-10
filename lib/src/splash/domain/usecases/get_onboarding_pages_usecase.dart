import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/splash/domain/entities/onboarding_page_entity.dart';
import 'package:link_vault/src/splash/domain/repositories/onboarding_repository.dart';

class GetOnboardingPagesUsecase {
  final OnboardingRepository _onboardingRepository;

  GetOnboardingPagesUsecase(this._onboardingRepository);

  Future<Either<Failure, List<OnboardingPageEntity>>> call() =>
      _onboardingRepository.getOnboardingPages();
}
