import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/splash/domain/entities/onboarding_page_entity.dart';
import 'package:link_vault/src/splash/domain/usecases/save_has_seen_onboarding_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/watch_has_seen_onboarding_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final WatchHasSeenOnboardingUsecase _watchHasSeenOnboardingUsecase;
  final SaveHasSeenOnboardingUsecase _saveHasSeenOnboardingUsecase;
  // StreamSubscription<Either<Failure, bool>>? _onboardingSubscription;

  OnboardingBloc(
    this._watchHasSeenOnboardingUsecase,
    this._saveHasSeenOnboardingUsecase,
  ) : super(OnboardingInitialState()) {
    on<LoadOnboardingPageEvent>(_onLoadOnBoardingPages);
    on<PageChangedEvent>(_onPageChanged);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);

    // _onboardingSubscription ??= _watchHasSeenOnboardingUsecase.call().listen(
    //   (hasSeenOnboardingRes) {
    //     hasSeenOnboardingRes.fold(
    //       (_) {},
    //       (hasSeenOnboarding) {
    //         if (hasSeenOnboarding) {
    //           add(CompleteOnboardingEvent());
    //         }
    //       },
    //     );
    //   },
    // );
  }

  Future<void> _onLoadOnBoardingPages(
    OnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoadingState());

    // await
  }

  Future<void> _onPageChanged(
    OnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {}

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
