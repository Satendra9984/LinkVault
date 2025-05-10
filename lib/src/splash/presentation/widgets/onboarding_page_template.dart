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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: size.width,
            height: size.height * 0.45,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
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
