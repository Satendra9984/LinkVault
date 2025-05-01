import 'package:flutter/material.dart';

class SplashScreenTemplate extends StatelessWidget {
  const SplashScreenTemplate({
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
    return Padding(
      padding: EdgeInsets.symmetric(),
      child: Column(
        children: [],
      ),
    );
  }
}
