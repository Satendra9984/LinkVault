import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';

part 'email_verification_event.dart';
part 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AuthRepository _authRepository;

  EmailVerificationBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(EmailVerificationInitial()) {
    on<ResendVerificationEmail>(_onResendVerificationEmail);
    on<VerifyEmailToken>(_onVerifyEmailToken);
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmail event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(EmailVerificationLoading());
    final result = await _authRepository.resendEmailVerification(event.email);

    result.fold(
      (failed) {
        emit(EmailVerificationError(failed.errorMessage));
      },
      (resentSuccess) {
        emit(EmailVerificationResent());
      },
    );
  }

  Future<void> _onVerifyEmailToken(
    VerifyEmailToken event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(EmailVerificationLoading());

    final result = await _authRepository.verifyEmailToken(
      authCode: event.authCode,
    );

    result.fold(
      (failed) {
        emit(EmailVerificationError(failed.errorMessage));
      },
      (success) {
        emit(EmailVerificationSuccess());
      },
    );
  }
}
