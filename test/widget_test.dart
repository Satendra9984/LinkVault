// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:link_vault/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';

void main() {
  testWidgets('OnboardingPageIndicator renders correct dot count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OnboardingPageIndicator(currentPage: 1, itemCount: 3),
        ),
      ),
    );

    final dots = find.descendant(
      of: find.byType(OnboardingPageIndicator),
      matching: find.byType(Container),
    );

    expect(dots, findsNWidgets(3));
  });
}
