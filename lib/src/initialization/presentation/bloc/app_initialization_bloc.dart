import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/injections/app_providers.dart';
import 'package:link_vault/src/splash/data/models/typedefs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_initialization_event.dart';
part 'app_initialization_state.dart';

class AppInitializationBloc extends Cubit<AppInitializationState> {
  final SupabaseClientSetter setSupabaseClient;
  final IsarSetter setIsarClient;

  AppInitializationBloc(
    {
      required this.setIsarClient,
      required this.setSupabaseClient,
    }
  ) : super(AppInitializationInitial());

  Future<void> initialize() async {
    emit(AppInitializationLoading());

    try {
      await Future.wait(
        [
          _initializeSupabase(),
          _initializeIsar(),
        ],
      );

      // Then initialize feature-specific providers if needed
      _initializeFeatures();

      emit(AppInitializationLoaded());
    } catch (e) {
      emit(AppInitializationErrorLoading());
    }
  }

  Future<void> _initializeSupabase() async {
    final supabase = await Supabase.initialize(
      url: 'https://xyzcompany.supabase.co',
      anonKey: 'public-anon-key',
    );

    setSupabaseClient(supabase.client);
  }

  Future<void> _initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [],
      directory: dir.path,
    );

    setIsarClient(isar);
  }

  /// Example: Pre-initialize repositories or services that should be ready at startup
  /// ref.read(userRepositoryProvider); // Forces initialization of user repository
  /// ref.read(settingsServiceProvider); // Forces initialization of settings service

  /// You could also trigger initial data loads:
  /// ref.read(appConfigProvider.notifier).loadConfig();
  void _initializeFeatures() {}
}
