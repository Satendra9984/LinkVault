import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/models/forget_password_states.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {

  ForgetPasswordCubit({
    required AuthRepositoryImpl authRepoIml,
  })  : _authRepositoryImpl = authRepoIml,
        super(
          const ForgetPasswordState(
            forgetPasswordStates: ForgetPasswordStates.initial,
            email: '',
          ),
        );
  final AuthRepositoryImpl _authRepositoryImpl;

  Future<void> sendResetPasswordLink({required String email}) async {
    emit(
      state.copyWith(
        forgetPasswordStates: ForgetPasswordStates.sendingEmailLink,
        email: email,
      ),
    );

    final result =
        await _authRepositoryImpl.sendPasswordResetLink(emailAddress: email);

    // debugPrint('[log] : $result');

    result.fold(
      (failed) => {
        emit(
          state.copyWith(
            forgetPasswordStates:
                ForgetPasswordStates.errorSendingResetPasswordLink,
            email: email,
            forgetPasswordFailure: failed,
          ),
        ),
      },
      (success) => {
        emit(
          state.copyWith(
            forgetPasswordStates:
                ForgetPasswordStates.resetPasswordLinkSentSuccessfully,
            email: email,
          ),
        ),
      },
    );
  }
}
