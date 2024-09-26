part of 'rss_feed_cubit.dart';

class RssFeedState extends Equatable {
  const RssFeedState({
    required this.feedCollections,
  });

  final Map<String, RssFeedModel> feedCollections;

  RssFeedState copyWith({
    Map<String, RssFeedModel>? feedCollections,
  }) {
    return RssFeedState(
      feedCollections: feedCollections ?? this.feedCollections,
    );
  }

  @override
  List<Object> get props => [feedCollections];
}

class RssFeedModel extends Equatable {
  const RssFeedModel({
    required this.allFeeds,
    required this.loadingStates,
    required this.loadingMoreStates,
  });

  final List<UrlModel> allFeeds;
  final LoadingStates loadingStates;
  final LoadingStates loadingMoreStates;

  RssFeedModel copyWith({
    List<UrlModel>? allFeeds,
    LoadingStates? loadingStates,
    LoadingStates? loadingMoreStates,
  }) {
    return RssFeedModel(
      allFeeds: allFeeds ?? this.allFeeds,
      loadingStates: loadingStates ?? this.loadingStates,
      loadingMoreStates: loadingMoreStates ?? this.loadingMoreStates,
    );
  }

  // toString method for easier debugging and logging
  @override
  String toString() {
    return 'RssFeedState(allFeeds: $allFeeds, loadingStates: $loadingStates, loadingMoreStates: $loadingMoreStates)';
  }

  // Initial state constructor for convenience
  factory RssFeedModel.initial() {
    return const RssFeedModel(
      allFeeds: [],
      loadingStates: LoadingStates.initial,
      loadingMoreStates: LoadingStates.initial,
    );
  }

  @override
  List<Object> get props => [
        allFeeds,
        loadingStates,
        loadingMoreStates,
      ];
}
