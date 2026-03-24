import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/entities/onboarding_slide.dart';
import '../../../../core/constants/app_assets.dart';

class OnboardingState {
  final int currentPage;
  final List<OnboardingSlide> slides;

  const OnboardingState({
    required this.currentPage,
    required this.slides,
  });

  OnboardingState copyWith({int? currentPage, List<OnboardingSlide>? slides}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      slides: slides ?? this.slides,
    );
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(() {
  return OnboardingNotifier();
});

class OnboardingNotifier extends Notifier<OnboardingState> {
  late final CompleteOnboardingUseCase _completeOnboarding;

  @override
  OnboardingState build() {
    // Migrated from UserPreferencesRepository to objectbox-backed AppSettingsRepository
    _completeOnboarding =
        CompleteOnboardingUseCase(ref.watch(appSettingsRepositoryProvider));

    return const OnboardingState(
      currentPage: 0,
      slides: [
        OnboardingSlide(
          title: 'Save Links',
          imagePath: AppAssets.onboardingSave,
          description: 'Capture any URL in seconds so it never gets lost.',
        ),
        OnboardingSlide(
          title: 'Organize',
          imagePath: AppAssets.onboardingOrganize,
          description: 'Put links into collections and keep everything tidy.',
        ),
        OnboardingSlide(
          title: 'Sync Anywhere',
          imagePath: AppAssets.onboardingAct,
          description: 'Ready on every device (cloud sync coming in later sprints).',
        ),
      ],
    );
  }

  void updatePage(int index) {
    state = state.copyWith(currentPage: index);
  }

  Future<void> completeOnboarding() async {
    await _completeOnboarding();
  }

  bool get isLastPage => state.currentPage == state.slides.length - 1;
}
