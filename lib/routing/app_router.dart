import 'package:go_router/go_router.dart';
import 'package:link_vault/src/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}
