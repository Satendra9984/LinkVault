import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Regression: `/collections/create` must not be matched by `/collections/:id`
/// with `id == "create"` (which also breaks `extra` typing for create flow).
/// Mirrors route order in [lib/core/router/app_router.dart].
void main() {
  testWidgets('GoRouter resolves /collections/create to static create route',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/collections/create',
      routes: [
        GoRoute(
          path: '/collections/create',
          builder: (_, __) => const Scaffold(
            body: Text('CREATE_ROUTE'),
          ),
        ),
        GoRoute(
          path: '/collections/:id',
          builder: (_, state) => Scaffold(
            body: Text('ID_ROUTE:${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('CREATE_ROUTE'), findsOneWidget);
    expect(find.textContaining('ID_ROUTE'), findsNothing);
  });
}
