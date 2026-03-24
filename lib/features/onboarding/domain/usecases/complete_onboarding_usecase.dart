import '../../../../core/data/repositories/app_settings_repository.dart';

/// Marks onboarding as completed using the objectbox-backed [AppSettingsRepository].
class CompleteOnboardingUseCase {
  final AppSettingsRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  Future<void> call() => _repository.markOnboardingSeen();
}
