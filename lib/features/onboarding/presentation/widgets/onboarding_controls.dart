import 'package:flutter/material.dart';
import 'onboarding_page_indicator.dart';

class OnboardingControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPressed;

  const OnboardingControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OnboardingPageIndicator(
            currentPage: currentPage,
            itemCount: totalPages,
          ),
          ElevatedButton(
            onPressed: onNextPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              currentPage == totalPages - 1 ? 'Get Started' : 'Next',
            ),
          ),
        ],
      ),
    );
  }
}
