import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/network_image_cache_model.dart';
import 'package:link_vault/src/dashboard/services/url_parsing_service.dart';

part 'network_image_cache_state.dart';

class NetworkImageCacheCubit extends Cubit<NetworkImageCacheState> {
  NetworkImageCacheCubit()
      : super(
          const NetworkImageCacheState(
            imagesData: {},
          ),
        );

  void addImage(
    String imageUrl, {
    required bool compressImage,
  }) async {
    final imagesData = {...state.imagesData};

    var networkImageCacheModel = NetworkImageCacheModel(
      loadingState: LoadingStates.loading,
      imageUrl: imageUrl,
    );
    imagesData[imageUrl] = networkImageCacheModel;
    emit(
      state.copyWith(
        imagesData: imagesData,
      ),
    );

    // [TODO] : USE LOCAL STORAGE IF AVAILABLE
    final imageBytes = await UrlParsingService.fetchImageAsUint8List(
      imageUrl,
      maxSize: 2 * 1024 * 1024, // 2MB
      compressImage: compressImage,
    );

    final imagesData2 = {...state.imagesData};

    if (imageBytes == null) {
      networkImageCacheModel = networkImageCacheModel.copyWith(
        loadingState: LoadingStates.errorLoading,
      );
    } else {
      networkImageCacheModel = networkImageCacheModel.copyWith(
        imageBytesData: imageBytes,
        loadingState: LoadingStates.loaded,
      );
    }

    imagesData2[imageUrl] = networkImageCacheModel;
    emit(
      state.copyWith(
        imagesData: imagesData2,
      ),
    );
  }

  NetworkImageCacheModel? getImageData(String imageUrl) {
    final imageData = state.imagesData[imageUrl];

    // if (imageData == null) {
    //   imageData = NetworkImageCacheModel(
    //     loadingState: LoadingStates.loading,
    //     imageUrl: imageUrl,
    //   );

    //   addImage(imageUrl);
    // }
    return imageData;
  }
}
