import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/core/services/storage_services.dart';
import 'package:link_vault/core/theme/app_themes.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/routing/app_router.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/shared/presentation/blocs/local_app_settings_cubit/local_app_settings_cubit.dart';
import 'package:link_vault/src/shared/shared_app_providers.dart';

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
    final splashBloc = ref.watch(splashBlocProvider);
    // final authBloc = ref.watch(authBlocProvider);
    // final homeBloc = ref.watch(homeBlocProvider);
    // ... other blocs
    // Create the Cubit and pass the ref
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocalAppSettingsCubit()),
        BlocProvider.value(value: splashBloc),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final appRouter = ref.watch(routeProvider);
          return BlocBuilder<LocalAppSettingsCubit, LocalAppSettings>(
            builder: (context, state) {
              return MaterialApp.router(
                title: 'LinkVault',
                routerConfig: appRouter,
                theme: AppThemes.getThemeDataFromString(state.themeMode.value),
                // theme: AppThemes.getThemeDataFromString('dark'),
              );
            },
          );
        },
      ),
    );
  }
}
