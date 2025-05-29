part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class LoadOnboardingPageEvent extends OnboardingEvent {}

class PageChangedEvent extends OnboardingEvent {
  PageChangedEvent(this.pageIndex);

  final int pageIndex;

  @override
  List<Object> get props => [pageIndex];
}

class CompleteOnboardingEvent extends OnboardingEvent {}
