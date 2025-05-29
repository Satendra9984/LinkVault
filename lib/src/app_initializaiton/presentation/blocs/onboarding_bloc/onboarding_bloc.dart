import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/app_initializaiton/domain/entities/onboarding_page_entity.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/get_onboarding_pages_usecase.dart';
import 'package:link_vault/src/app_initializaiton/domain/usecases/save_has_seen_onboarding_usecase.dart';
// import 'package:link_vault/src/splash/domain/usecases/watch_has_seen_onboarding_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SaveHasSeenOnboardingUsecase _saveHasSeenOnboardingUsecase;
  final GetOnboardingPagesUsecase _getOnboardingPagesUsecase;

  OnboardingBloc(
    this._saveHasSeenOnboardingUsecase,
    this._getOnboardingPagesUsecase,
  ) : super(OnboardingInitialState()) {
    on<LoadOnboardingPageEvent>(_onLoadOnBoardingPages);
    on<PageChangedEvent>(_onPageChanged);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  Future<void> _onLoadOnBoardingPages(
    OnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoadingState());

    await _getOnboardingPagesUsecase().then(
      (res) {
        res.fold(
          (failed) {
            emit(OnboardingErrorState(failed.errorMessage));
          },
          (pages) {
            emit(
              OnboardingLoadedState(
                pages: pages,
                currentPageIndex: 0,
                isLastPage: pages.length == 1,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onPageChanged(
    PageChangedEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoadedState) {
      final currentState = state as OnboardingLoadedState;

      emit(
        currentState.copyWith(
          currentPageIndex: event.pageIndex,
          isLastPage: event.pageIndex == currentState.pages.length - 1,
        ),
      );
    }
  }

  Future<void> _onCompleteOnboarding(
    OnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    await _saveHasSeenOnboardingUsecase.call(true).then(
      (res) {
        res.fold(
          (failed) {
            emit(OnboardingErrorState(failed.errorMessage));
          },
          (_) {
            emit(OnboardingCompletedState());
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    // _onboardingSubscription?.cancel();
    return super.close();
  }
}
