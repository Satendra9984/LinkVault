import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:link_vault/core/enums/loading_states.dart';

class NetworkImageCacheModel extends Equatable {
  const NetworkImageCacheModel({
    required this.loadingState,
    required this.imageUrl,
    this.imageBytesData,
    this.errorMessage,
  });

  final LoadingStates loadingState;
  final String imageUrl;
  final Uint8List? imageBytesData;
  final String? errorMessage;

  @override
  List<Object?> get props =>
      [loadingState, imageUrl, imageBytesData, errorMessage];

  // copyWith method
  NetworkImageCacheModel copyWith({
    LoadingStates? loadingState,
    String? imageUrl,
    Uint8List? imageBytesData,
    String? errorMessage,
  }) {
    return NetworkImageCacheModel(
      loadingState: loadingState ?? this.loadingState,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytesData: imageBytesData ?? this.imageBytesData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
