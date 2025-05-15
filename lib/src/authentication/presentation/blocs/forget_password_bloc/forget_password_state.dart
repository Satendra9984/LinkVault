part of 'forget_password_bloc.dart';

// ForgetPasswordState
class ForgetPasswordState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String errorMessage;
  
  ForgetPasswordState({
    required this.isSubmitting,
    required this.isSuccess,
    required this.isFailure,
    required this.errorMessage,
  });
  
  factory ForgetPasswordState.initial() => ForgetPasswordState(
    isSubmitting: false,
    isSuccess: false,
    isFailure: false,
    errorMessage: '',
  );
  
  ForgetPasswordState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
