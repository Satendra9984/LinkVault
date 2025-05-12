import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';
import './login_event.dart';
import './login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginState.initial()) {
    on<LoginWithCredentials>(_onLoginWithCredentials);
    on<ForgotPassword>(_onForgotPassword);
  }

  Future<void> _onLoginWithCredentials(
    LoginWithCredentials event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
      errorMessage: '',
    ));

    final result = await authRepository.signInWithEmailPassword(
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      )),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
      errorMessage: '',
    ));

    final result = await authRepository.sendPasswordResetEmail(event.email);

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      )),
    );
  }
}
