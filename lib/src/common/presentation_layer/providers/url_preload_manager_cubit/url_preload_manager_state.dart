part of 'url_preload_manager_cubit.dart';

class UrlPreloadManagerState extends Equatable {
  const UrlPreloadManagerState({
    this.urlPreloadsData = const {},
  });

  // Factory constructor for initial state
  factory UrlPreloadManagerState.initial() {
    return const UrlPreloadManagerState();
  }

  final Map<String, bool> urlPreloadsData;

  // Copy with method to create a new instance with modified values
  UrlPreloadManagerState copyWith({
    Map<String, bool>? urlPreloadsData,
  }) {
    return UrlPreloadManagerState(
      urlPreloadsData: urlPreloadsData ?? this.urlPreloadsData,
    );
  }

  // Check if a specific URL is preloaded
  bool isUrlPreloaded(String url) {
    return urlPreloadsData[url] ?? false;
  }

  // Get all preloaded URLs
  List<String> get preloadedUrls {
    return urlPreloadsData.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Get count of preloaded URLs
  int get preloadedCount {
    return preloadedUrls.length;
  }

  // Check if any URLs are preloaded
  bool get hasPreloadedUrls {
    return preloadedUrls.isNotEmpty;
  }

  @override
  List<Object> get props => [urlPreloadsData];

  @override
  String toString() {
    return 'UrlPreloadManagerState(urlPreloadsData: $urlPreloadsData)';
  }
}
