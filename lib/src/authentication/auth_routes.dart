import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/routing/route_params.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/auth_providers.dart';
import 'package:link_vault/src/authentication/presentation/screens/auth_home.dart';
import 'package:link_vault/src/authentication/presentation/screens/forget_password/password_reset_check_email_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/forget_password/password_reset.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/email_verified_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/login_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/signup_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/verify_your_mail.dart';

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
            builder: (context, state) {
              final email = state.uri.queryParameters['email'];
              // Logger.printLog('[forgetpass] email: ${state.uri.queryParameters}');
              return BlocProvider.value(
                value: ref.watch(forgetPasswordBlocProvider),
                child: ForgetPasswordResetPage(
                  email: email,
                ),
              );
            },
          ),
          GoRoute(
            path: RoutePaths.checkEmail,
            builder: (context, state) {
              final email = state.pathParameters['email'] ?? '';

              return PasswordResetCheckEmailPage(
                email: email,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.signUp,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: ref.watch(signupBlocProvider),
              ),
              BlocProvider.value(
                value: ref.watch(emailVerificationBlocProvider),
              ),
            ],
            child: const SignUpPage(),
          );
        },
        routes: [
          GoRoute(
            path: RoutePaths.verifyEmail,
            builder: (context, state) {
              final email = state.uri.queryParameters['email'] ?? '';

              return BlocProvider.value(
                value: ref.watch(emailVerificationBlocProvider),
                child: VerifyEmailPage(
                  email: email,
                ),
              );
            },
          ), // New routes for email verification deeplinks
          GoRoute(
            path: RoutePaths.emailVerification,
            builder: (context, state) {
              final authCode = state.uri.queryParameters['code'];

              return BlocProvider.value(
                value: ref.watch(emailVerificationBlocProvider),
                child: EmailVerifiedPage(
                  authToken: authCode,
                ),
              );
            },
          ),
        ],
      ),
    ];
  },
);
