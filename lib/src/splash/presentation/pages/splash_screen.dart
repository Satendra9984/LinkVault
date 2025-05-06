import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/shared/presentation/blocs/local_app_settings_cubit/local_app_settings_cubit.dart';
import 'package:link_vault/src/splash/presentation/bloc/splash_bloc.dart';

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
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding) {
            context.read<LocalAppSettingsCubit>().updateLocalAppSettings(
                  state.localAppSettings,
                );
            context.go(RoutePaths.onboarding);
          } else if (state is SplashNavigateToHome) {
            context.read<LocalAppSettingsCubit>().updateLocalAppSettings(
                  state.localAppSettings,
                );
          } else if (state is SplashNavigateToLogin) {
            context.read<LocalAppSettingsCubit>().updateLocalAppSettings(
                  state.localAppSettings,
                );
          }
        },
        child: Center(
          child: Text(
            'LinkVault',
            style: theme.textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }
}
