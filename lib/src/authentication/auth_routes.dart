import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/routing/route_params.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/auth_providers.dart';
import 'package:link_vault/src/authentication/presentation/screens/auth_home.dart';
import 'package:link_vault/src/authentication/presentation/screens/forget_password/password_reset.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/login_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/signup_page.dart';

final authRoutesProvider = Provider(
  (ref) {
    return [
      GoRoute(
        path: RoutePaths.authHome,
        builder: (context, state) => const AuthHome(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) {
          final returnPath = state.pathParameters[RouteParams.returnToPath];

          return BlocProvider.value(
            value: ref.watch(loginBlocProvider),
            child: LoginPage(
              returnPath: returnPath,
            ),
          );
        },
        routes: [
          GoRoute(
            path: RoutePaths.forgetPassword,
            builder: (context, state) => BlocProvider.value(
              value: ref.watch(forgetPasswordBlocProvider),
              child: const ForgetPasswordResetPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.signUp,
        builder: (context, state) => BlocProvider.value(
          value: ref.watch(signupBlocProvider),
          child: const SignUpPage(),
        ),
      ),
    ];
  },
);
