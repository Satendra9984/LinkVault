part of 'network_image_cache_cubit.dart';

class NetworkImageFileCacheState extends Equatable {
  const NetworkImageFileCacheState({required this.imagesData});

  final Map<String, ValueNotifier<NetworkImageCacheModel>> imagesData;

  @override
  List<Object> get props => [imagesData];

  NetworkImageFileCacheState copyWith({
    Map<String, ValueNotifier<NetworkImageCacheModel>>? imagesData,
  }) {
    return NetworkImageFileCacheState(
      imagesData: imagesData ?? this.imagesData,
    );
  }
}
