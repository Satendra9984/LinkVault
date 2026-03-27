import 'package:flutter/material.dart';
import 'onboarding_page_indicator.dart';

/// Bottom controls row: dot indicators (left) + full-width CTA button (below).
/// The layout is a Column so the pill button is always full-width.
class OnboardingControls extends StatelessWidget {
  const OnboardingControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNextPressed,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPressed;

  bool get _isLast => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OnboardingPageIndicator(
            currentPage: currentPage,
            itemCount: totalPages,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onNextPressed,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                _isLast ? 'Get Started →' : 'Next →',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
