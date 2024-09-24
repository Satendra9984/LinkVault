// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/constants/user_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/subsciption/data/datasources/subsciption_remote_data_sources.dart';

class RewardedAdRepoImpl {
  RewardedAdRepoImpl({
    required SubsciptionRemoteDataSources subsciptionRemoteDataSources,
  }) : _subsciptionRemoteDataSources = subsciptionRemoteDataSources;

  final SubsciptionRemoteDataSources _subsciptionRemoteDataSources;

  RewardedAd? _rewardedAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  final _adUnitId = Platform.isAndroid
      // USE THESE KEYS FOR PRODUCTION
      ? 'ca-app-pub-9004947579124903/9607023869'
      : 'ca-app-pub-9004947579124903/9180149465';

  // Below are test ads
  // ? 'ca-app-pub-3940256099942544/5224354917'
  // : 'ca-app-pub-3940256099942544/1712485313';
  Future<Either<ServerFailure, Unit>> loadAd() async {
    final completer = Completer<Either<ServerFailure, Unit>>();

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) async {
          // Logger.printLog('$ad loaded.');
          _rewardedAd = ad;
          if (!completer.isCompleted) {
            completer.complete(const Right(unit));
          }
        },
        onAdFailedToLoad: (onAdFailedToLoad) {
          debugPrint(
            '[log] : error loading ad ${onAdFailedToLoad.domain} ${onAdFailedToLoad.code} ${onAdFailedToLoad.message} ${onAdFailedToLoad.responseInfo?.responseExtras}',
          );
          if (!completer.isCompleted) {
            completer.complete(
              Left(
                ServerFailure(
                  message:
                      'Video Not Loaded. Check Internet Connection and try again.',
                  statusCode: 400,
                ),
              ),
            );
          }
        },
      ),
    ).catchError(
      (e) {
        Logger.printLog('[ads] : $e');
        if (!completer.isCompleted) {
          completer.complete(
            Left(
              ServerFailure(
                message:
                    'Video Not Loaded. Check Internet Connection and try again.',
                statusCode: 400,
              ),
            ),
          );
        }
      },
    );

    return completer.future;
  }

  Future<Either<Failure, GlobalUser>> showRewardedAd({
    required GlobalUser globalUser,
  }) async {
    try {
      num rewardAmount = 0;

      if (_rewardedAd == null) {
        // debugPrint('[log] : ad is null');
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
