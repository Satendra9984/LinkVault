// lib/core/di/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/authentication/data/datasources/auth_local_data_source.dart';
import 'package:link_vault/src/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:link_vault/src/authentication/data/repository/auth_repository_impl.dart';
import 'package:link_vault/src/authentication/data/repository/user_repository_impl.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';
import 'package:link_vault/src/authentication/domain/repository/user_repository.dart';
import 'package:link_vault/src/authentication/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:link_vault/src/shared/shared_app_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Connectivity
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// Data sources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(
    isar: ref.read(storageServiceProvider).isar,
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    supabaseClient: ref.read(storageServiceProvider).supabaseClient,
  );
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
    connectivity: ref.read(connectivityProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
    connectivity: ref.read(connectivityProvider),
  );
});

// BLoCs
final authBlocProvider = Provider<AuthBloc>((ref) {
  return AuthBloc(
    authRepository: ref.read(authRepositoryProvider),
    userRepository: ref.read(userRepositoryProvider),
  )..add(AppStarted());
});

final loginBlocProvider = Provider<LoginBloc>((ref) {
  return LoginBloc(
    authRepository: ref.read(authRepositoryProvider),
  );
});

final signupBlocProvider = Provider<SignupBloc>((ref) {
  return SignupBloc(
    authRepository: ref.read(authRepositoryProvider),
    authBloc: ref.read(authBlocProvider),
  );
});

final userProfileBlocProvider = Provider<UserProfileBloc>((ref) {
  return UserProfileBloc(
    userRepository: ref.read(userRepositoryProvider),
  )..add(LoadUserProfile());
});
