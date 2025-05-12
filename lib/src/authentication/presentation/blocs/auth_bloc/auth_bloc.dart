import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/authentication/domain/entities/user_profile.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';
import 'package:link_vault/src/authentication/domain/repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  late StreamSubscription<bool> _authSubscription;

  AuthBloc({
    required this.authRepository,
    required this.userRepository,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<CheckAuth>(_onCheckAuth);
    on<UserLoggedIn>(_onUserLoggedIn);
    on<UserSignedUp>(_onUserSignedUp);
    on<UserLoggedOut>(_onUserLoggedOut);

    // Subscribe to auth state changes
    _authSubscription = authRepository.authStateChanges.listen((isAuthenticated) {
      if (isAuthenticated) {
        authRepository.getCurrentUserId().then((userId) {
          if (userId != null) {
            add(UserLoggedIn(userId));
          }
        });
      } else {
        add(UserLoggedOut());
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final isSignedIn = await authRepository.isSignedIn();
    
    if (isSignedIn) {
      final userId = await authRepository.getCurrentUserId();
      if (userId != null) {
        add(UserLoggedIn(userId));
      } else {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onCheckAuth(CheckAuth event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final isSignedIn = await authRepository.isSignedIn();
    
    if (isSignedIn) {
      final userId = await authRepository.getCurrentUserId();
      if (userId != null) {
        add(UserLoggedIn(userId));
      } else {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onUserLoggedIn(UserLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await userRepository.getUserProfile();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (profile) => emit(Authenticated(profile)),
    );
  }

  Future<void> _onUserSignedUp(UserSignedUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await userRepository.getUserProfile();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (profile) => emit(Authenticated(profile)),
    );
  }

  Future<void> _onUserLoggedOut(UserLoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
