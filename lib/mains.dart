import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/core/services/storage_services.dart';
import 'package:link_vault/routing/app_router.dart';
import 'package:link_vault/src/initialization/presentation/screens/linkvault_init.dart';
import 'package:link_vault/src/shared/app_themes.dart';
import 'package:link_vault/src/splash/presentation/pages/splash_screen.dart';

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
    // final authBloc = ref.watch(authBlocProvider);
    // final homeBloc = ref.watch(homeBlocProvider);
    // ... other blocs
    // Create the Cubit and pass the ref
    return Consumer(
      builder: (context, ref, _) {
        final appRouter = ref.watch(routeProvider);
        return MaterialApp.router(
          title: 'LinkVault',
          routerConfig: appRouter,
          theme: AppThemes.lightTheme,
        );
      },
    );
  }
}
