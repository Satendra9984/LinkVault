// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/onboarding/data/repositories/models/loading_states.dart';

part 'onboarding_state.dart';

class OnBoardCubit extends Cubit<OnBoardState> {
  OnBoardCubit({
    required AuthRepositoryImpl authRepoImpl,
  })  : _authRepoImpl = authRepoImpl,
        super(
          const OnBoardState(
            onBoardingStates: OnBoardingStates.initial,
          ),
        );
  final AuthRepositoryImpl _authRepoImpl;

  Future<void> checkIfLoggedIn() async {
    final stopwatch = Stopwatch()..start();
    // Logger.printLog(
    //     '[INITAPP][CKIFLOGGEDIN] : ${stopwatch.elapsedMilliseconds}',);

    final result = await _authRepoImpl.isLoggedIn();

    result.fold(
      (failed) {
        emit(state.copyWith(onBoardingStates: OnBoardingStates.notLoggedIn));
      },
      (globalUser) {
        if (globalUser != null) {
          emit(
            state.copyWith(
              onBoardingStates: OnBoardingStates.isLoggedIn,
              globalUser: globalUser,
            ),
          );
        } else {
          emit(state.copyWith(onBoardingStates: OnBoardingStates.notLoggedIn));
        }
      },
    );

    stopwatch.stop();
    // Logger.printLog(
    //     '[INITAPP][CKIFLOGGEDIN] : ${stopwatch.elapsedMilliseconds}',);
  }

  bool isCreditExpired() {
    if (state.globalUser == null) {
      return true;
    }

    final todayDate = DateTime.now().toUtc();

    final userCreditExpiryDate = state.globalUser!.creditExpiryDate.toUtc();

    if (userCreditExpiryDate.compareTo(todayDate) < 0) {
      return true;
    }

    return false;
  }

  Future<void> deleteUserForever() async {}
}
