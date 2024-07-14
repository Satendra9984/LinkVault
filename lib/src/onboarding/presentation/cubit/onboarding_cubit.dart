// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/firebase_options.dart';
import 'package:link_vault/src/onboarding/data/repositories/on_boarding_repo_impl.dart';
import 'package:link_vault/src/onboarding/presentation/models/loading_states.dart';

part 'onboarding_state.dart';

class OnBoardCubit extends Cubit<OnBoardState> {
  OnBoardCubit({
    required OnBoardingRepoImpl onBoardingRepoImpl,
  })  : _boardingRepoImpl = onBoardingRepoImpl,
        super(
          const OnBoardState(
            onBoardingStates: OnBoardingStates.initial,
          ),
        );
  final OnBoardingRepoImpl _boardingRepoImpl;

  Future<void> checkIfLoggedIn() async {

    final result = await _boardingRepoImpl.isLoggedIn();
    debugPrint('Current state before emit: $state');

    result.fold(
      (failed) {
        // debugPrint('Emitting notLoggedIn');
        emit(state.copyWith(onBoardingStates: OnBoardingStates.notLoggedIn));
      },
      (globalUser) {
        if (globalUser != null) {
          // debugPrint('Emitting isLoggedIn');
          emit(
            state.copyWith(
              onBoardingStates: OnBoardingStates.isLoggedIn,
              globalUser: globalUser,
            ),
          );
        } else {
          // debugPrint('Emitting notLoggedIn false');
          emit(state.copyWith(onBoardingStates: OnBoardingStates.notLoggedIn));
        }
      },
    );
    debugPrint('Current state after emit: $state');
  }

  bool isCreditExpired() {
    debugPrint('[log] : listening isCreditExpired called');

    if (state.globalUser == null) {
      debugPrint('[log] : state.global == null returning true');

      return true;
    }

    final todayDate = DateTime.now().toUtc();

    final userCreditExpiryDate = state.globalUser!.creditExpiryDate.toUtc();
    // Testing check the dates

    // debugPrint('[log] : currentTime ${todayDate}');
    // debugPrint('[log] : expiryTime ${userCreditExpiryDate}');
    // debugPrint(
    //   '[log] : expiryTimeBefore ${userCreditExpiryDate.isBefore(todayDate)}',
    // );

    // debugPrint(
    //   '[log] : ${todayDate.day}/${todayDate.month}/${todayDate.year}:${todayDate.hour}:${todayDate.minute}::${todayDate.second}',
    // );
    // debugPrint(
    //   '[log] : ${userCreditExpiryDate.day}/${userCreditExpiryDate.month}/${userCreditExpiryDate.year}::${userCreditExpiryDate.hour}:${userCreditExpiryDate.minute}/${userCreditExpiryDate.second}',
    // );

    if (userCreditExpiryDate.compareTo(todayDate) < 0) {
      return true;
    }

    return false;
  }
}
