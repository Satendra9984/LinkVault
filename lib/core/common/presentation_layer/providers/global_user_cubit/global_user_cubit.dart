// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/repository_layer/models/global_user_model.dart';

part 'global_user_state.dart';

class GlobalUserCubit extends Cubit<GlobalUserState> {
  GlobalUserCubit()
      : super(
          const GlobalUserState(
            globalUser: null,
          ),
        );

  void initializeGlobalUser(GlobalUser globleUser) {
    emit(
      state.copyWith(
        globalUser: globleUser,
      ),
    );
    debugPrint('[log] : ${globleUser.toJson()}');
  }

  GlobalUser? getGlobalUser() {
    return state.globalUser;
  }
}
