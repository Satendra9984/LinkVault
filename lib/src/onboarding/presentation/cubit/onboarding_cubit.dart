import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/onboarding/data/repositories/on_boarding_repo_impl.dart';
import 'package:link_vault/src/onboarding/presentation/models/loading_states.dart';

part 'onboarding_state.dart';

class OnBoardCubit extends Cubit<OnBoardState> {
  final OnBoardingRepoImpl _boardingRepoImpl;

  OnBoardCubit({
    required OnBoardingRepoImpl onBoardingRepoImpl,
  })  : _boardingRepoImpl = onBoardingRepoImpl,
        super(
          const OnBoardState(
            onBoardingStates: OnBoardingStates.initial,
          ),
        );

  void checkIfLoggedIn() {
    final result = _boardingRepoImpl.isLoggedIn();
    debugPrint('Current state before emit: $state');

    result.fold(
      (failed) {
        // debugPrint('Emitting notLoggedIn');
        emit(state.copyWith(onBoardingStates: OnBoardingStates.notLoggedIn));
      },
      (loginRes) {
        if (loginRes == true) {
          // debugPrint('Emitting isLoggedIn');
          emit(state.copyWith(onBoardingStates: OnBoardingStates.isLoggedIn));
        } else {
          // debugPrint('Emitting notLoggedIn false');
          emit(state.copyWith(onBoardingStates: OnBoardingStates.notLoggedIn));
        }
      },
    );
    debugPrint('Current state after emit: $state');
  }
}
