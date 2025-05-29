import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/core/services/app_initialization_service.dart';
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

class LinkVaultApp extends ConsumerStatefulWidget {
  const LinkVaultApp({Key? key}) : super(key: key);

  @override
  ConsumerState<LinkVaultApp> createState() => _LinkVaultAppState();
}

class _LinkVaultAppState extends ConsumerState<LinkVaultApp> {
  late final AppInitializationService _appInitializationService;

  @override
  void initState() {
    super.initState();
    _appInitializationService = ref.read(appInitializationServiceProvider);
    _appInitializationService.initialize();
  }

  @override
  void dispose() {
    _appInitializationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            debugShowCheckedModeBanner: false,
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
