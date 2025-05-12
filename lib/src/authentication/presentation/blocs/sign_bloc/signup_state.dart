import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String errorMessage;

  const SignupState({
    required this.isSubmitting,
    required this.isSuccess,
    required this.isFailure,
    required this.errorMessage,
  });

  factory SignupState.initial() {
    return const SignupState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
      errorMessage: '',
    );
  }

  SignupState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
  }) {
    return SignupState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, isFailure, errorMessage];
}