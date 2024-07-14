import 'dart:async';
import 'dart:collection';
// import 'dart:isolate';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/network_image_cache_model.dart';
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

  // final IsolateManager _isolateManager = IsolateManager();
  // bool _isIsolateManagerInitialized = false;
  // final FetchQueue _fetchQueue = FetchQueue();

  // Future<void> initialize() async {
  //   if (_isIsolateManagerInitialized == false) {
  //     await _isolateManager.initialize().then(
  //           (value) => _isIsolateManagerInitialized = true,
  //         );
  //   }
  // }

  Future<Uint8List?> fetchImageInIsolate(
    String imageUrl, {
    int maxSize = 2 * 102 * 1024,
    bool compressImage = true,
  }) async {
    return await UrlParsingService.fetchImageAsUint8List(
      imageUrl,
      maxSize: maxSize,
      compressImage: compressImage,
    );
  }

  void addImage(
    String imageUrl, {
    required bool compressImage,
  }) async {
    final imagesData = {...state.imagesData};

    var networkImageCacheModel = NetworkImageCacheModel(
      loadingState: LoadingStates.loading,
      imageUrl: imageUrl,
    );
    imagesData[imageUrl] = ValueNotifier(networkImageCacheModel);
    emit(
      state.copyWith(
        imagesData: imagesData,
      ),
    );

    // [TODO] : USE LOCAL STORAGE IF AVAILABLE
    // await _isolateManager
    //     .fetchImageInIsolate(
    //   imageUrl,
    //   compressImage: compressImage,
    // )

    // _fetchQueue.add(
    //   // need not to add await as then it will wait for result here itself
    //   // and defeats the purpose of using a queue
    //   () =>
      
      await UrlParsingService.fetchImageAsUint8List(
        imageUrl,
        maxSize: 2 * 102 * 1024,
        compressImage: compressImage,
      ).then(
        (imageBytes) {
          // final imagesData2 = {...state.imagesData};

          Logger.printLog(
            '[Image][isolate] : ${imageUrl} ${imageBytes != null}',
          );

          var addedImageModel = getImageData(imageUrl) ??
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
            );
          }

          // imagesData2[imageUrl] = networkImageCacheModel;
          // emit(
          //   state.copyWith(
          //     imagesData: imagesData2,
          //   ),
          // );
        },
      // ),
    );

    // final imageBytes = await UrlParsingService.fetchImageAsUint8List(
    //   imageUrl,
    //   maxSize: 2 * 100 * 1024, // 2MB
    //   compressImage: compressImage,
    // );

    // final imagesData2 = {...state.imagesData};

    // if (imageBytes == null) {
    //   networkImageCacheModel = networkImageCacheModel.copyWith(
    //     loadingState: LoadingStates.errorLoading,
    //   );
    // } else {
    //   networkImageCacheModel = networkImageCacheModel.copyWith(
    //     imageBytesData: imageBytes,
    //     loadingState: LoadingStates.loaded,
    //   );
    // }

    // imagesData2[imageUrl] = networkImageCacheModel;
    // emit(
    //   state.copyWith(
    //     imagesData: imagesData2,
    //   ),
    // );
  }

  ValueNotifier<NetworkImageCacheModel>? getImageData(String imageUrl) {
    final imageData = state.imagesData[imageUrl];
   
    if(imageData == null) {

    }

    return imageData;
  }
}

class FetchQueue {
  final Queue<Function> _tasks = Queue<Function>();
  bool _isRunning = false;

  void add(Function task) {
    _tasks.add(task);
    _processNext();
  }

  void _processNext() {
    if (_isRunning || _tasks.isEmpty) {
      return;
    }

    _isRunning = true;
    final task = _tasks.removeFirst();
    task().then((_) {
      _isRunning = false;
      _processNext();
    });
  }
}

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
