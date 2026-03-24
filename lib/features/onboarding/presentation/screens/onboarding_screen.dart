import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_controls.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(OnboardingNotifier notifier, OnboardingState state) {
    if (state.currentPage < state.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(notifier);
    }
  }

  Future<void> _completeOnboarding(OnboardingNotifier notifier) async {
    await notifier.completeOnboarding();
    if (mounted) {
      // Always navigate to the Welcome/Auth screen after onboarding.
      // The router redirect will automatically push already-authenticated
      // users to '/' so no double-redirect occurs.
      context.go('/auth/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      // backgroundColor: Colors.white, // REMOVED: Respect theme
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(notifier),
                child: const Text('Skip'),
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingState.slides.length,
                onPageChanged: (index) {
                  notifier.updatePage(index);
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(data: onboardingState.slides[index]);
                },
              ),
            ),

            // Controls
            OnboardingControls(
              currentPage: onboardingState.currentPage,
              totalPages: onboardingState.slides.length,
              onNextPressed: () => _onNextPressed(notifier, onboardingState),
            ),
          ],
        ),
      ),
    );
  }
}
