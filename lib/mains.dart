import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/core/services/storage_services.dart';
import 'package:link_vault/core/theme/app_themes.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/app_theme_cubit/app_theme_cubit.dart';
import 'package:link_vault/src/authentication/auth_providers.dart';

// https://codewithandrea.com/articles/robust-app-initialization-riverpod/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: LinkVaultApp(),
    ),
  );
}

class LinkVaultApp extends ConsumerWidget {
  const LinkVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get all your BLoCs from Riverpod
    final appRouter = ref.watch(routeProvider);
    final themeBloc = ref.watch(themeBlocProvider);
    final authBloc = ref.watch(authBlocProvider);
    final userProfileBloc = ref.watch(userProfileBlocProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeBloc),
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: userProfileBloc),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'LinkVault',
            routerConfig: appRouter,
            theme: AppThemes.getThemeDataFromString(
              state.appThemeMode.value,
              // 'dark',
            ),
          );
        },
      ),
    );
  }
}
