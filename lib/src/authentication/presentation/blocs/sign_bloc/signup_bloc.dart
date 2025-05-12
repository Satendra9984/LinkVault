import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';
import 'package:link_vault/src/authentication/presentation/blocs/auth_bloc/auth_bloc.dart';
import './signup_event.dart';
import './signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;
  final AuthBloc authBloc;

  SignupBloc({
    required this.authRepository,
    required this.authBloc,
  }) : super(SignupState.initial()) {
    on<SignupWithCredentials>(_onSignupWithCredentials);
  }

  Future<void> _onSignupWithCredentials(
    SignupWithCredentials event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
      errorMessage: '',
    ));

    final result = await authRepository.signUpWithEmailPassword(
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: failure.message,
      )),
      (user) {
        authBloc.add(UserSignedUp(user.id));
        emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        ));
      },
    );
  }
}