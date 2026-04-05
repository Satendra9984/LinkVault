import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/core/presentation/widgets/empty_state_view.dart';

void main() {
  testWidgets('renders CTA with semantic label', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: EmptyStateView(
          imageAsset: 'assets/images/empty.png',
          title: 'Nothing here',
          message: 'Try again later.',
          buttonText: 'Retry',
          onButtonPressed: () => tapped = true,
        ),
      ),
    );

    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Retry'), findsWidgets);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(tapped, isTrue);
    semantics.dispose();
  });
}
