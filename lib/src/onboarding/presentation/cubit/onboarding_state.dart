part of 'onboarding_cubit.dart';

class OnBoardState extends Equatable {

  const OnBoardState({
    required this.onBoardingStates,
  });
  final OnBoardingStates onBoardingStates;

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
