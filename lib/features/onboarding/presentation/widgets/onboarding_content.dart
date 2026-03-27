import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_slide.dart';

/// Single onboarding slide.
/// Layout: illustration zone (56% of screen height) + title + description.
class OnboardingContent extends StatelessWidget {
  const OnboardingContent({super.key, required this.data});

  final OnboardingSlide data;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final illustrationHeight = size.height * 0.56;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Illustration zone ─────────────────────────────────────────────
        SizedBox(
          height: illustrationHeight,
          width: double.infinity,
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.contain,
          ),
        ),

        // ── Text ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
