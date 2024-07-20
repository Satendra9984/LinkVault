import 'dart:async';
import 'dart:collection';
// import 'dart:isolate';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/services/queue_manager.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/data_sources/local_image_data_source.dart';
import 'package:link_vault/src/dashboard/data/models/network_image_cache_model.dart';
import 'package:link_vault/src/dashboard/data/services/image_decoder.dart';
// import 'package:link_vault/src/dashboard/data/services/isolate_manager.dart';
import 'package:link_vault/src/dashboard/services/url_parsing_service.dart';

part 'network_image_cache_state.dart';

class NetworkImageCacheCubit extends Cubit<NetworkImageCacheState> {
  NetworkImageCacheCubit()
      : super(
          const NetworkImageCacheState(
            imagesData: {},
          ),
        );

  final LocalImageDataSource _localImageDataSource = LocalImageDataSource();

  final AsyncQueueManager _imageQueueManager = AsyncQueueManager();

  Future<Uint8List?> fetchImageInIsolate(
    String imageUrl, {
    int maxSize = 2 * 102 * 1024,
    bool compressImage = true,
  }) async {
    return UrlParsingService.fetchImageAsUint8List(
      imageUrl,
      maxSize: maxSize,
      compressImage: compressImage,
      quality: 75,
    );
  }

  Future<void> addImage(
    String imageUrl, {
    required bool compressImage,
  }) async {
    final imagesData = {...state.imagesData};

    final networkImageCacheModel = NetworkImageCacheModel(
      loadingState: LoadingStates.loading,
      imageUrl: imageUrl,
    );
    imagesData[imageUrl] = ValueNotifier(networkImageCacheModel);
    emit(
      state.copyWith(
        imagesData: imagesData,
      ),
    );

    final localImageBytes = await _localImageDataSource.getImageData(imageUrl);

    Logger.printLog('isarImage: ${localImageBytes != null}');

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

    if (imageBytes == null) {
      addedImageModel.value = addedImageModel.value.copyWith(
        loadingState: LoadingStates.errorLoading,
      );
    } else {
      addedImageModel.value = addedImageModel.value.copyWith(
        imageBytesData: imageBytes,
        loadingState: LoadingStates.loaded,
        // uiImage: uiImage,
      );

      if (localImageBytes == null) {
        await _localImageDataSource.addImageData(
          imageUrl: imageUrl,
          imageBytes: imageBytes,
        );
      }

      // final uiImage = await ImageDecodeManager.decodeImage(imageBytes);

      // _imageQueueManager.addTask(
      //   () async {
      //     final uiImage = await ImageDecodeManager.decodeImage(imageBytes);

      //     final newImagesstateWithUiImage = {...state.imagesData};

      //     newImagesstateWithUiImage[imageUrl] = ValueNotifier(
      //       addedImageModel.value.copyWith(
      //         imageBytesData: imageBytes,
      //         loadingState: LoadingStates.loaded,
      //         uiImage: uiImage,
      //       ),
      //     );

      //     emit(
      //       state.copyWith(
      //         imagesData: newImagesstateWithUiImage,
      //       ),
      //     );
      //   },
      // );
    }
  }

  ValueNotifier<NetworkImageCacheModel>? getImageData(String imageUrl) {
    final imageData = state.imagesData[imageUrl];

    // if (imageData == null) {}

    return imageData;
  }
}



// final ImageQueueManager _imageQueueManager = ImageQueueManager();

// class IsolateManager {
//   final _queue = <_IsolateTask>[];
//   bool _isProcessing = false;

//   Future<Uint8List?> fetchImageInIsolate(String imageUrl,
//       {int maxSize = 2 * 102 * 1024, bool compressImage = true}) async {
//     final task = _IsolateTask(
//       imageUrl: imageUrl,
//       maxSize: maxSize,
//       compressImage: compressImage,
//     );
//     _queue.add(task);
//     await _processQueue();
//     return task.result;
//   }

//   Future<void> _processQueue() async {
//     if (_isProcessing) return;
//     _isProcessing = true;

//     while (_queue.isNotEmpty) {
//       final task = _queue.first;

//       // task.result = await compute(fetchImage, task.imageUrl);
//       task.result = await UrlParsingService.fetchImageAsUint8List(
//         task.imageUrl,
//         maxSize: task.maxSize,
//         compressImage: task.compressImage,
//       );
//       _queue.removeAt(0);
//       task.completer.complete();
//     }

//     _isProcessing = false;
//   }

//   Future<Uint8List?> fetchImage(String imageUrl,
//       {int maxSize = 2 * 102 * 1024, bool compressImage = true}) async {
//     return await UrlParsingService.fetchImageAsUint8List(
//       imageUrl,
//       maxSize: maxSize,
//       compressImage: compressImage,
//     );
//   }
// }

// class _IsolateTask {
//   final String imageUrl;
//   final int maxSize;
//   final bool compressImage;
//   Uint8List? result;
//   final Completer<void> completer = Completer<void>();

//   _IsolateTask({
//     required this.imageUrl,
//     required this.maxSize,
//     required this.compressImage,
//   });
// }
