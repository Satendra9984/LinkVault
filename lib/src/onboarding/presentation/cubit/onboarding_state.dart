part of 'onboarding_cubit.dart';

class OnBoardState extends Equatable {
  const OnBoardState({
    required this.onBoardingStates,
    this.globalUser,
  });
  final OnBoardingStates onBoardingStates;
  final GlobalUser? globalUser;

  OnBoardState copyWith({
    OnBoardingStates? onBoardingStates,
    GlobalUser? globalUser,
  }) {
    return OnBoardState(
      onBoardingStates: onBoardingStates ?? this.onBoardingStates,
      globalUser: globalUser ?? this.globalUser,
    );
  }

  @override
  List<Object?> get props => [
        onBoardingStates,
        globalUser,
      ];
}
