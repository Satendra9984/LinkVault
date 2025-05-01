import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:link_vault/src/common/repository_layer/enums/loading_states.dart';

class NetworkImageCacheModel extends Equatable {
  const NetworkImageCacheModel({
    required this.loadingState,
    required this.imageUrl,
    this.imageBytesData,
    this.errorMessage,
    this.imageSize,
    this.file,
    this.uiImage,
  });

  final LoadingStates loadingState;
  final String imageUrl;
  final File? file;
  final Uint8List? imageBytesData;
  final ui.Size? imageSize;
  final String? errorMessage;
  final ui.Image? uiImage;

  @override
  List<Object?> get props => [
        loadingState,
        imageUrl,
        imageBytesData,
        errorMessage,
        uiImage,
        file,
        imageSize,
      ];

  // copyWith method
  NetworkImageCacheModel copyWith({
    LoadingStates? loadingState,
    String? imageUrl,
    Uint8List? imageBytesData,
    File? file,
    ui.Size? imageSize,
    String? errorMessage,
    ui.Image? uiImage,
  }) {
    return NetworkImageCacheModel(
      loadingState: loadingState ?? this.loadingState,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytesData: imageBytesData ?? this.imageBytesData,
      errorMessage: errorMessage ?? this.errorMessage,
      file: file ?? this.file,
      uiImage: uiImage ?? this.uiImage,
      imageSize: imageSize ?? this.imageSize,
    );
  }
}
