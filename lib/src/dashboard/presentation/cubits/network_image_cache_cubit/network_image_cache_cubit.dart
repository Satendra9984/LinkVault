// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/services/queue_manager.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/src/app_home/services/custom_image_cache_manager.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';
import 'package:link_vault/src/dashboard/data/data_sources/local_image_data_source.dart';
import 'package:link_vault/src/dashboard/data/models/network_image_cache_model.dart';

part 'network_image_cache_state.dart';

// Top-level function for image processing to run in isolate
Future<Uint8List?> compressAndFetchImage(
  Map<String, dynamic> params,
) async {
  final imageUrl = params['imageUrl'] as String;
  final compressImage = params['compressImage'] as bool;
  final maxSize = params['maxSize'] as int;

  // // Logger.printLog('[img] : computing $imageUrl');
  final result = await UrlParsingService.fetchImageAsUint8List(
    imageUrl,
    maxSize: maxSize,
    compressImage: compressImage,
    quality: 75,
  );

  // // Logger.printLog('[img] : computed ${result != null}');
  return result;
}

class NetworkImageCacheCubit extends Cubit<NetworkImageCacheState> {
  NetworkImageCacheCubit()
      : super(const NetworkImageCacheState(imagesData: {}));

  final LocalImageDataSource _localImageDataSource = LocalImageDataSource();
  final AsyncQueueManager _imageQueueManager = AsyncQueueManager();

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

    // // Logger.printLog('[img] : $imageUrl addImage');
    // Add the image loading task to the queue manager
    // _imageQueueManager.addTask(
    //   () async {
    final stopWatch = Stopwatch()..start();
    final localImageBytes = await _localImageDataSource.getImageData(imageUrl);

    // // Logger.printLog(
    //   '[img] : ${stopWatch.elapsedMilliseconds}ms in local storage ${localImageBytes != null}',
    // );

    final imageBytes = localImageBytes ??
        await UrlParsingService.fetchImageAsUint8List(
          imageUrl,
          maxSize: 2 * 102 * 1024,
          compressImage: compressImage,
          quality: 75,
        );
    stopWatch.stop();

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

      // if (fetchUiImage) {
      //   final receivePort = ReceivePort();
      //   await Isolate.spawn(
      //     ImageUtils.decodeImageIsolate,
      //     [imageBytes, receivePort.sendPort],
      //   );

      //   final result = await receivePort.first as List<int>?;
      //   if (result != null) {
      //     final completer = Completer<ui.Image>();
      //     ui.decodeImageFromList(
      //       Uint8List.fromList(result),
      //       completer.complete,
      //     );

      //     uiImage = await completer.future;
      //   }
      // }

      addedImageModel.value = addedImageModel.value.copyWith(
        imageBytesData: imageBytes,
        loadingState: LoadingStates.loaded,
        uiImage: uiImage,
      );

      // Cache image locally if not already cached
      if (localImageBytes == null) {
        // // Logger.printLog('[img] : ${imageUrl} storing in local storage');
        await _localImageDataSource.addImageData(
          imageUrl: imageUrl,
          imageBytes: imageBytes,
        );
      }
      stopWatch.stop();
      // // Logger.printLog(
      //   '[img] : stop ${stopWatch.elapsedMilliseconds}ms storing in local storage',
      // );
    }
    // },
    // );
  }

  Future<NetworkImageCacheModel?> fetchUrlModel({
    required String imageUrl,
    bool compressImage = true,
    bool fetchUiImage = true,
  }) async {
    final stopWatch = Stopwatch()..start();
    final localImageBytes = await _localImageDataSource.getImageData(imageUrl);

    // // Logger.printLog(
    //   '[img] : ${stopWatch.elapsedMilliseconds}ms in local storage ${localImageBytes != null}',
    // );

    final imageBytes = localImageBytes ??
        await UrlParsingService.fetchImageAsUint8List(
          imageUrl,
          maxSize: 2 * 102 * 1024,
          compressImage: compressImage,
          quality: 75,
        );

    final addedImageModel = ValueNotifier(
      NetworkImageCacheModel(
        loadingState: LoadingStates.loading,
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

      if (fetchUiImage) {
        final receivePort = ReceivePort();
        await Isolate.spawn(
          ImageUtils.decodeImageIsolate,
          [imageBytes, receivePort.sendPort],
        );

        final result = await receivePort.first as List<int>?;
        if (result != null) {
          final completer = Completer<ui.Image>();
          ui.decodeImageFromList(
            Uint8List.fromList(result),
            completer.complete,
          );

          uiImage = await completer.future;
        }
      }

      addedImageModel.value = addedImageModel.value.copyWith(
        imageBytesData: imageBytes,
        loadingState: LoadingStates.loaded,
        uiImage: uiImage,
      );

      // Cache image locally if not already cached
      if (localImageBytes == null) {
        // // Logger.printLog('[img] : ${imageUrl} storing in local storage');
        await _localImageDataSource.addImageData(
          imageUrl: imageUrl,
          imageBytes: imageBytes,
        );
      }
      stopWatch.stop();
      // // Logger.printLog(
      //   '[img] : stop ${stopWatch.elapsedMilliseconds}ms storing in local storage',
      // );
    }

    return addedImageModel.value;
  }

  Future<NetworkImageCacheModel?> fetchUrlModelFromCacheNetwork({
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
        (fileInfo) async {
          if (fileInfo == null) {
            imagesData[imageUrl] = ValueNotifier(
              NetworkImageCacheModel(
                loadingState: LoadingStates.errorLoading,
                imageUrl: imageUrl,
              ),
            );
            emit(state.copyWith(imagesData: imagesData));
            return;
          }

          // fileInfo.file.le
          // final imageBytes = await fileInfo.file.readAsBytes();
          // final fileSize =
          // // ImageUtils.getImageDimFromUintData(imageBytes) ??
          //     const ui.Size(1, 1);

          imagesData[imageUrl] = ValueNotifier(
            NetworkImageCacheModel(
              loadingState: LoadingStates.loaded,
              imageUrl: imageUrl,
              file: fileInfo.file,
              // imageSize: fileSize,
            ),
          );
          emit(state.copyWith(imagesData: imagesData));
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
    return null;
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
