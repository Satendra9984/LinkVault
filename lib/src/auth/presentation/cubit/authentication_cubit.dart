import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/models/auth_states_enum.dart';
import 'package:link_vault/src/onboarding/presentation/models/loading_states.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepositoryImpl _authRepositoryImpl;

  AuthenticationCubit({
    required AuthRepositoryImpl authRepositoryImpl,
  })  : _authRepositoryImpl = authRepositoryImpl,
        super(
          const AuthenticationState(
            authenticationStates: AuthenticationStates.initial,
          ),
        );

  Future<void> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(authenticationStates: AuthenticationStates.signingUp));
    var result = await _authRepositoryImpl.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failed) {
        emit(
          state.copyWith(
              authenticationStates: AuthenticationStates.errorSigningUp),
        );
      },
      (result) {
        emit(state.copyWith(
            authenticationStates: AuthenticationStates.signedUp));
      },
    );
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(authenticationStates: AuthenticationStates.signingIn));
    var result = await _authRepositoryImpl.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failed) {
        emit(
          state.copyWith(
              authenticationStates: AuthenticationStates.errorSigningIn),
        );
      },
      (result) {
        emit(state.copyWith(
            authenticationStates: AuthenticationStates.signedIn));
      },
    );
  }
}
