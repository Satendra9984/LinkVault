import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/on_boarding/presentation/screens/onboarding_home.dart';
import 'package:link_vault/src/splash/presentation/pages/splash_screen.dart';

final routeProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      redirect: (context, state) {
        // final user = ref.read(currentUserProvider).asData?.value;
        // final isFirstTime = ref.read(isFirstTimeProvider);

        // // If not logged in, go to login
        // if (user == null && state.location != '/login') {
        //   return '/login';
        // }
        // // If first run and not onboarding, go to onboarding
        // if (user != null && isFirstTime && state.location != '/onboarding') {
        //   return '/onboarding';
        // }
        // // If authenticated and trying to go to login/onboarding, send to home
        // if (user != null &&
        //     (state.location == '/login' || state.location == '/onboarding')) {
        //   return '/home';
        // }
        // Otherwise, no redirect
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        // GoRoute(path: '/login', builder: (c, s) => LoginPage()),
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (c, s) => OnBoardingHomePage(),
        ),
        // ShellRoute(
        //   // Example ShellRoute with BottomNavigationBar
        //   builder: (context, state, child) => Scaffold(
        //     body: child,
        //     bottomNavigationBar: MyBottomNavBar(state),
        //   ),
        //   routes: [
        //     GoRoute(path: '/home', builder: (c, s) => HomePage()),
        //     GoRoute(path: '/urls', builder: (c, s) => UrlsPage()),
        //     GoRoute(path: '/collections', builder: (c, s) => CollectionsPage()),
        //   ],
        // ),
      ],
    );
  },
);
