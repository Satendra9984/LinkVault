part of 'network_image_cache_cubit.dart';

class NetworkImageCacheState extends Equatable {
  const NetworkImageCacheState({required this.imagesData});

  final Map<String, NetworkImageCacheModel> imagesData;
  
  @override
  List<Object> get props => [imagesData];

  NetworkImageCacheState copyWith({
    Map<String, NetworkImageCacheModel>? imagesData,
  }) {
    return NetworkImageCacheState(
      imagesData: imagesData ?? this.imagesData,
    );
  }
}
