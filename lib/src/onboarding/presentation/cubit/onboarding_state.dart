part of 'onboarding_cubit.dart';

class OnBoardState extends Equatable {
  final OnBoardingStates onBoardingStates;

  const OnBoardState({
    required this.onBoardingStates,
  });

  OnBoardState copyWith({
    OnBoardingStates? onBoardingStates,
  }) {
    return OnBoardState(
      onBoardingStates: onBoardingStates ?? this.onBoardingStates,
    );
  }

  @override
  List<Object> get props => [onBoardingStates];
}
