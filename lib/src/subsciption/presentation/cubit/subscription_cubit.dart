import 'package:equatable/equatable.dart';
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

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  Future<void> loadRewardedAd() async {
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

  Future<void> showRewardedAd({
    required GlobalUser globalUser,
  }) async {
    final loadResult = await _adRepoImpl.showRewardedAd(globalUser: globalUser);

    loadResult.fold(
      (failed) {
        emit(
          state.copyWith(
            videoWatchingStates: LoadingStates.errorLoading,
          ),
        );
      },
      (newGlobalUser) {
        emit(
          state.copyWith(
            videoWatchingStates: LoadingStates.loaded,
            globalUser: newGlobalUser,
          ),
        );
      },
    );
  }
}
