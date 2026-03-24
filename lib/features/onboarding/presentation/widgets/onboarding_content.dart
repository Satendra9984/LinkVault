// ignore_for_file: deprecated_member_use
import 'dart:math';

import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_slide.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingSlide data;

  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final pageSize = MediaQuery.sizeOf(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Image.asset(
            data.imagePath,
            height: max(pageSize.height * 0.5, 300),
            fit: BoxFit.contain,
          ),
          // const SizedBox(height: 12),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(179), // 0.7 opacity
                ),
          ),
        ],
      ),
    );
  }
}
