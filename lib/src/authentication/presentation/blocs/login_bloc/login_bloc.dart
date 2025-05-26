import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_event.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginState.initial()) {
    on<LoginWithCredentials>(_onLoginWithCredentials);
  }

  Future<void> _onLoginWithCredentials(
    LoginWithCredentials event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        isSuccess: false,
        isFailure: false,
        errorMessage: '',
      ),
    );

    final result = await authRepository.signInWithEmailPassword(
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          isFailure: true,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        ),
      ),
    );
  }
}
