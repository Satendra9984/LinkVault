import 'package:flutter/material.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int itemCount;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.only(right: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
