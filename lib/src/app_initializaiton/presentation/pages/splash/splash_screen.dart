import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/core/utils/logger.dart';

import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/splash_bloc/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // // AFTER super.initState()
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // flutter_bloc lookup
    //   context.read<SplashBloc>().add(SplashInitialEvent());

    // });
    // Using Future.microtask to ensure the context is completely built
    Future.microtask(() {
      context.read<SplashBloc>().add(SplashInitialEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          Logger.printLog('[splashstate] : $state');

          if (state is SplashNavigateToOnboarding) {
            context.go(RoutePaths.onboarding);
          } else if (state is SplashNavigateToHome) {
            context.go(RoutePaths.home);
          } else if (state is SplashNavigateToLogin) {
            context.go(RoutePaths.authHome);
          }
        },
        builder: (context, state) {
          return Center(
            child: Text(
              'LinkVault',
              style: theme.textTheme.headlineLarge,
            ),
          );
        },
      ),
    );
  }
}
