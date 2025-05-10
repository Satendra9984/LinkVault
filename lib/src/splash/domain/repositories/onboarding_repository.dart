import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/splash/domain/entities/onboarding_page_entity.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardingPageEntity>>> getOnboardingPages();
}
