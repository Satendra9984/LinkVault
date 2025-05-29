// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/services/url_parsing_service.dart';
import 'package:link_vault/src/common/data_layer/data_sources/local_data_sources/local_image_data_source.dart';
import 'package:link_vault/src/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/src/common/repository_layer/models/network_image_cache_model.dart';

part 'network_image_cache_state.dart';


class NetworkImageCacheCubit extends Cubit<NetworkImageCacheState> {
  NetworkImageCacheCubit()
      : super(const NetworkImageCacheState(imagesData: {}));

  final LocalImageDataSource _localImageDataSource = LocalImageDataSource();
  // final AsyncQueueManager _imageQueueManager = AsyncQueueManager();

  Future<void> addImage(
    String imageUrl, {
    required bool compressImage,
    bool fetchUiImage = false,
  }) async {
    final imagesData = {...state.imagesData};

    final networkImageCacheModel = NetworkImageCacheModel(
      loadingState: LoadingStates.loading,
      imageUrl: imageUrl,
    );

    imagesData[imageUrl] = ValueNotifier(networkImageCacheModel);

    emit(state.copyWith(imagesData: imagesData));

    final localImageBytes = await _localImageDataSource.getImageData(imageUrl);

    final imageBytes = localImageBytes ??
        await UrlParsingService.fetchImageAsUint8List(
          imageUrl,
          maxSize: 2 * 102 * 1024,
          compressImage: compressImage,
          quality: 75,
        );

    final addedImageModel = getImageData(imageUrl) ??
        ValueNotifier(
          NetworkImageCacheModel(
            loadingState: LoadingStates.errorLoading,
            imageUrl: imageUrl,
          ),
        );

    // Handle image loading states
    if (imageBytes == null) {
      addedImageModel.value = addedImageModel.value.copyWith(
        loadingState: LoadingStates.errorLoading,
      );
    } else {
      ui.Image? uiImage;

      addedImageModel.value = addedImageModel.value.copyWith(
        imageBytesData: imageBytes,
        loadingState: LoadingStates.loaded,
        uiImage: uiImage,
      );

      // Cache image locally if not already cached
      if (localImageBytes == null) {
        await _localImageDataSource.addImageData(
          imageUrl: imageUrl,
          imageBytes: imageBytes,
        );
      }

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
