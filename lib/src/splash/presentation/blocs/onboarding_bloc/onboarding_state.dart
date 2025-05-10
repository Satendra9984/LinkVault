part of 'onboarding_bloc.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

final class OnboardingInitialState extends OnboardingState {}

final class OnboardingLoadingState extends OnboardingState {}

final class OnboardingLoadedState extends OnboardingState {
  OnboardingLoadedState({
    required this.pages,
    required this.currentPageIndex,
    required this.isLastPage,
  });

  final List<OnboardingPageEntity> pages;
  final int currentPageIndex;
  final bool isLastPage;

  OnboardingLoadedState copyWith({
    List<OnboardingPageEntity>? pages,
    int? currentPageIndex,
    bool? isLastPage,
  }) {
    return OnboardingLoadedState(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }

  @override
  List<Object> get props => [pages, currentPageIndex, isLastPage];
}

class OnboardingCompletingState extends OnboardingState {}

class OnboardingCompletedState extends OnboardingState {}

class OnboardingErrorState extends OnboardingState {
  final String message;

  OnboardingErrorState(this.message);

  @override
  List<Object> get props => [message];
}
