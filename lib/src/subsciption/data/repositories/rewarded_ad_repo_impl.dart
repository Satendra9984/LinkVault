// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_vault/core/common/constants/user_constants.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/subsciption/data/datasources/subsciption_remote_data_sources.dart';

class RewardedAdRepoImpl {
  RewardedAdRepoImpl({
    required SubsciptionRemoteDataSources subsciptionRemoteDataSources,
  }) : _subsciptionRemoteDataSources = subsciptionRemoteDataSources;

  final SubsciptionRemoteDataSources _subsciptionRemoteDataSources;

  RewardedAd? _rewardedAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  final _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-9004947579124903/9607023869'
      : 'ca-app-pub-9004947579124903/9180149465';

  Future<Either<Failure, Unit>> loadAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (onAdFailedToLoad) {
            throw ServerException(
              message: 'Video Not loaded',
              statusCode: 400,
            );
          },
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Video Not Loaded. Check Internet Connection and try again.',
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, GlobalUser>> showRewardedAd({
    required GlobalUser globalUser,
  }) async {
    try {
      num rewardAmount = 0;
      await _rewardedAd?.show(
        onUserEarnedReward: (adWithoutView, reward) {
          rewardAmount = reward.amount;
          debugPrint('[log] : user earned $rewardAmount');
        },
      );

      final currentExpiryDate = globalUser.creditExpiryDate;
      final nextExpiryDate = currentExpiryDate
          .add(
            const Duration(days: accountSingUpCreditLimit),
          );

      await _subsciptionRemoteDataSources.rewardUserForWatchingVideo(
        userId: globalUser.id,
        creditExpiryDate: nextExpiryDate.toIso8601String(),
      );

      final newGlobalUser =
          globalUser.copyWith(creditExpiryDate: nextExpiryDate);

      return Right(newGlobalUser);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Something Went Wrong',
          statusCode: 400,
        ),
      );
    }
  }
}
