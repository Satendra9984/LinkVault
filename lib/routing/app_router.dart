import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/routing/navigation_service.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/app_initializaiton/presentation/pages/onboarding/onboarding_home.dart';
import 'package:link_vault/src/app_initializaiton/presentation/pages/splash/splash_screen.dart';
import 'package:link_vault/src/authentication/auth_providers.dart';
import 'package:link_vault/src/authentication/auth_routes.dart';
import 'package:link_vault/src/authentication/presentation/screens/auth_home.dart';
import 'package:link_vault/src/authentication/presentation/screens/forget_password/password_reset.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/login_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/signup_page.dart';

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
          path: RoutePaths.splash,
          builder: (context, state) => BlocProvider(
            create: (_) => ref.watch(splashBlocProvider),
            child: const SplashScreen(),
          ),
        ),

        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) => BlocProvider(
            create: (_) => ref.watch(onboardingBlocProvider),
            child: const OnBoardingHomePage(),
          ),
        ),

        // GoRoute(
        //   path: RoutePaths.authHome,
        //   builder: (context, state) => const AuthHome(),
        // ),
        // GoRoute(
        //   path: RoutePaths.login,
        //   builder: (context, state) {
        //     return BlocProvider.value(
        //       value: ref.watch(loginBlocProvider),
        //       child: const LoginPage(),
        //     );
        //   },
        // ),
        // GoRoute(
        //   path: RoutePaths.signUp,
        //   builder: (context, state) => BlocProvider.value(
        //     value: ref.watch(signupBlocProvider),
        //     child: const SignUpPage(),
        //   ),
        // ),
        // GoRoute(
        //   path: RoutePaths.forgetPassword,
        //   builder: (context, state) => const ForgetPasswordResetPage(),
        // ),

        // Auth Routes
        ...ref.watch(authRoutesProvider),

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

final appNavigationProvider = Provider(
  (ref) {
    return GoRouterNavigationService(
      ref.watch(routeProvider),
    );
  },
);
