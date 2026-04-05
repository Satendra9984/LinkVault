import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Regression: global search filter routes must resolve under `/search`.
void main() {
  testWidgets('GoRouter resolves /search/filters/collections', (tester) async {
    final router = GoRouter(
      initialLocation: '/search/filters/collections',
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, __) => const Scaffold(body: Text('SEARCH_ROOT')),
          routes: [
            GoRoute(
              path: 'filters/collections',
              builder: (_, __) => const Scaffold(
                body: Text('COLLECTIONS_FILTERS'),
              ),
            ),
            GoRoute(
              path: 'filters/links',
              builder: (_, __) => const Scaffold(
                body: Text('LINKS_FILTERS'),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('COLLECTIONS_FILTERS'), findsOneWidget);
  });

  testWidgets('GoRouter resolves /search/filters/links', (tester) async {
    final router = GoRouter(
      initialLocation: '/search/filters/links',
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, __) => const Scaffold(body: Text('SEARCH_ROOT')),
          routes: [
            GoRoute(
              path: 'filters/collections',
              builder: (_, __) => const Scaffold(
                body: Text('COLLECTIONS_FILTERS'),
              ),
            ),
            GoRoute(
              path: 'filters/links',
              builder: (_, __) => const Scaffold(
                body: Text('LINKS_FILTERS'),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('LINKS_FILTERS'), findsOneWidget);
  });
}
