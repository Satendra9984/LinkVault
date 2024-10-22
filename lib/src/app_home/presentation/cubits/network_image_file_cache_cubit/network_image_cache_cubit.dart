// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/app_home/services/custom_image_cache_manager.dart';
import 'package:link_vault/src/dashboard/data/models/network_image_cache_model.dart';

part 'network_image_cache_state.dart';

// Top-level function for image processing to run in isolate
// Future<Uint8List?> compressAndFetchImage(
//   Map<String, dynamic> params,
// ) async {
//   final imageUrl = params['imageUrl'] as String;
//   final compressImage = params['compressImage'] as bool;
//   final maxSize = params['maxSize'] as int;

//   // Logger.printLog('[img] : computing $imageUrl');
//   final result = await UrlParsingService.fetchImageAsUint8List(
//     imageUrl,
//     maxSize: maxSize,
//     compressImage: compressImage,
//     quality: 75,
//   );

//   // Logger.printLog('[img] : computed ${result != null}');
//   return result;
// }

class NetworkImageFileCacheCubit extends Cubit<NetworkImageFileCacheState> {
  NetworkImageFileCacheCubit()
      : super(const NetworkImageFileCacheState(imagesData: {}));

  Future<void> fetchUrlModelFromCacheNetwork({
    required String imageUrl,
    required String collectionId,
  }) async {
    final imagesData = {...state.imagesData};

    final networkImageCacheModel = NetworkImageCacheModel(
      loadingState: LoadingStates.loading,
      imageUrl: imageUrl,
    );

    imagesData[imageUrl] = ValueNotifier(networkImageCacheModel);
    emit(state.copyWith(imagesData: imagesData));

    try {
      await CustomImagesCacheManager.instance
          .getImageFile(
        imageUrl,
        collectionId,
      )
          .then(
        (image) async {
          if (image == null) {
            imagesData[imageUrl] = ValueNotifier(
              NetworkImageCacheModel(
                loadingState: LoadingStates.errorLoading,
                imageUrl: imageUrl,
              ),
            );
            emit(state.copyWith(imagesData: imagesData));
            return;
          }

          await image.file.readAsBytes().then(
            (imageBytes) {
              imagesData[imageUrl] = ValueNotifier(
                NetworkImageCacheModel(
                  loadingState: LoadingStates.loaded,
                  imageUrl: imageUrl,
                  imageBytesData: imageBytes,
                ),
              );
              emit(state.copyWith(imagesData: imagesData));
            },
          );
        },
      );
    } catch (e) {
      imagesData[imageUrl] = ValueNotifier(
        NetworkImageCacheModel(
          loadingState: LoadingStates.errorLoading,
          imageUrl: imageUrl,
        ),
      );
      emit(state.copyWith(imagesData: imagesData));
    }
  }

  void updateStateWithList(
    Map<String, ValueNotifier<NetworkImageCacheModel>> images,
  ) {
    emit(
      state.copyWith(
        imagesData: {...state.imagesData, ...images},
      ),
    );
  }

  ValueNotifier<NetworkImageCacheModel>? getImageData(String imageUrl) {
    final imageData = state.imagesData[imageUrl];
    return imageData;
  }
}
