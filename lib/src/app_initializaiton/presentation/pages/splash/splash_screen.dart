import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/splash_bloc/splash_bloc.dart';
import 'package:link_vault/src/shared/presentation/blocs/local_app_settings_cubit/local_app_settings_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<SplashBloc>().add(SplashInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
         
          if (state is SplashNavigateToOnboarding) {
            context.go(RoutePaths.onboarding);
          } else if (state is SplashNavigateToHome) {
          } else if (state is SplashNavigateToLogin) {}
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
