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
      // [TODO] : USE THESE KEYS FOR PRODUCTION
      ? 'ca-app-pub-9004947579124903/9607023869'
      : 'ca-app-pub-9004947579124903/9180149465';

  // Below are test ads
  // ? 'ca-app-pub-3940256099942544/5224354917'
  // : 'ca-app-pub-3940256099942544/1712485313';

  Future<Either<Failure, Unit>> loadAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) async {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            // await Future.delayed(
            //   const Duration(seconds:7),
            // );
            _rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (onAdFailedToLoad) {
            debugPrint(
              '[log] : error loading ad ${onAdFailedToLoad.domain} ${onAdFailedToLoad.code} ${onAdFailedToLoad.message} ${onAdFailedToLoad.responseInfo?.responseExtras}',
            );
            throw ServerException(
              message: 'Video Not loaded',
              statusCode: 400,
            );
          },
        ),
      ).catchError((e) {
        debugPrint('[log][ads] : $e');
      });

      if (_rewardedAd == null) {
        throw ServerException(
          message: 'Video Not loaded',
          statusCode: 400,
        );
      }

      return const Right(unit);
    } catch (e) {
      debugPrint('[log] : ad video not loaded');

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

      if (_rewardedAd == null) {
        debugPrint('[log] : ad is null');
        throw ServerException(
          message:
              'Something Went Wrong. Video not Loaded. Check Internet Connection!!!',
          statusCode: 400,
        );
      }

      await _rewardedAd?.show(
        onUserEarnedReward: (adWithoutView, reward) {
          rewardAmount = reward.amount;
          debugPrint('[log] : user earned $rewardAmount');
        },
      );

      final currentTime = DateTime.now().toUtc();
      final nextExpiryDate = currentTime.add(
        // CONVERT TO DAYS
        const Duration(days: rewardedAdCreditLimit),
      );

      await _subsciptionRemoteDataSources.rewardUserForWatchingVideo(
        userId: globalUser.id,
        creditExpiryDate: nextExpiryDate.toIso8601String(),
      );

      final newGlobalUser =
          globalUser.copyWith(creditExpiryDate: nextExpiryDate);

      return Right(newGlobalUser);
    } on ServerException catch (e) {
      debugPrint('[log] : showad ${e.message}');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong. Check Internet and try again.',
          statusCode: 400,
        ),
      );
    } catch (e) {
      debugPrint('[log] : showad $e');
      return Left(
        ServerFailure(
          message: 'Something Went Wrong. Check Internet and try again.',
          statusCode: 400,
        ),
      );
    }
  }
}
