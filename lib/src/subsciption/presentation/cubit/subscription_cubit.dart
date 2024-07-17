import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/subsciption/data/repositories/rewarded_ad_repo_impl.dart';

part 'subscription_state.dart';

/// GOOGLE REWARDED ADS DOCS
// https://developers.google.com/admob/flutter/quick-start
// https://developers.google.com/admob/flutter/rewarded
// https://www.youtube.com/watch?v=QTrWKWjUA30

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required RewardedAdRepoImpl adRepoImpl,
  })  : _adRepoImpl = adRepoImpl,
        super(
          const SubscriptionState(
            loadingStates: LoadingStates.initial,
            videoWatchingStates: LoadingStates.initial,
          ),
        );
  final RewardedAdRepoImpl _adRepoImpl;

  bool _isSdkInitialized = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  Future<void> loadRewardedAd() async {
    debugPrint('[log] : loading a new ad');
    emit(
      state.copyWith(
        loadingStates: LoadingStates.loading,
      ),
    );

    if (_isSdkInitialized == false) {
      await initialize();
      _isSdkInitialized = !_isSdkInitialized;
    }

    final loadResult = await _adRepoImpl.loadAd();
    loadResult.fold(
      (failed) {
        emit(
          state.copyWith(
            loadingStates: LoadingStates.errorLoading,
          ),
        );
      },
      (loaded) {
        emit(
          state.copyWith(
            loadingStates: LoadingStates.loaded,
          ),
        );
      },
    );
  }

  Future<bool> showRewardedAd({
    required GlobalUser globalUser,
  }) async {
    emit(
      state.copyWith(
        videoWatchingStates: LoadingStates.loading,
      ),
    );
    final loadResult = await _adRepoImpl.showRewardedAd(globalUser: globalUser);

    var isLoaded = false;

    loadResult.fold(
      (failed) {
        emit(
          state.copyWith(
            videoWatchingStates: LoadingStates.errorLoading,
            loadingStates: LoadingStates.initial ,
          ),
        );
      },
      (newGlobalUser) {
        emit(
          state.copyWith(
            videoWatchingStates: LoadingStates.loaded,
            loadingStates: LoadingStates.initial,
            globalUser: newGlobalUser,
          ),
        );
        isLoaded = true;
      },
    );

    return isLoaded;
  }


  
}
