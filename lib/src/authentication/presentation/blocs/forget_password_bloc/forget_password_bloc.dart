import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';

part 'forget_password_event.dart';
part 'forget_password_state.dart';

class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final AuthRepository authRepository;

  ForgetPasswordBloc({required this.authRepository}) : super(ForgetPasswordState.initial()) {
    on<SendResetEmail>(_onSendResetEmail);
  }

  Future<void> _onSendResetEmail(
    SendResetEmail event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    
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
