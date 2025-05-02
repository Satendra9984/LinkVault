import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/src/initialization/presentation/bloc/app_initialization_bloc.dart';

//https://codewithandrea.com/articles/robust-app-initialization-riverpod/

class LinkVaultStartUpScreen extends ConsumerWidget {
  const LinkVaultStartUpScreen({
    super.key,
    required this.onLoaded,
  });

  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) => AppInitializationBloc(
        setSupabaseClient: (supabaseClinet) =>
            ref.read(supabaseClientProvider.notifier).state = supabaseClinet,
        setIsarClient: (isarClient) =>
            ref.read(isarProvider.notifier).state = isarClient,
      )..initialize(),
      child: BlocBuilder<AppInitializationBloc, AppInitializationState>(
        builder: (ctx, state) {
          if (state is AppInitializationLoaded) {
            return onLoaded(context);
          } else if (state is AppInitializationLoading) {
            return loadingState();
          } else if (state is AppInitializationErrorLoading) {
            return errorLoadingState();
          } else {
            return const Center();
          }
        },
      ),
    );
  }

  Widget loadingState() {
    return Center();
  }

  Widget errorLoadingState() {
    return Center();
  }

  Widget loadedState() {
    return Center();
  }
}
