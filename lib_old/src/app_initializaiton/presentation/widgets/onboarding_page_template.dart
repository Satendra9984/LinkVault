import 'package:flutter/material.dart';

class OnBoardingPageTemplate extends StatelessWidget {
  const OnBoardingPageTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pageNumber,
  });

  final String title;
  final String description;
  final String imageUrl;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final themeData = Theme.of(context);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: themeData.colorScheme.onPrimary,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: size.width,
            height: size.height * 0.45,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  title,
                  style: themeData.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: themeData.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
