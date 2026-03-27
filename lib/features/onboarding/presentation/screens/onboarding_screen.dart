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
      context.go('/auth/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main column: slides + controls ─────────────────────────────
            Column(
              children: [
                // Reserve space for the Skip button row
                const SizedBox(height: 48),

                // Slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingState.slides.length,
                    onPageChanged: notifier.updatePage,
                    itemBuilder: (context, index) => OnboardingContent(
                      data: onboardingState.slides[index],
                    ),
                  ),
                ),

                // Controls (dot indicator + CTA button)
                OnboardingControls(
                  currentPage: onboardingState.currentPage,
                  totalPages: onboardingState.slides.length,
                  onNextPressed: () =>
                      _onNextPressed(notifier, onboardingState),
                ),
              ],
            ),

            // ── Skip button – fixed top-right ──────────────────────────────
            Positioned(
              top: 4,
              right: 8,
              child: TextButton(
                onPressed: () => _completeOnboarding(notifier),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
