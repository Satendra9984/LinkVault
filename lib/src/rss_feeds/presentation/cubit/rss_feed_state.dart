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
    required this.refreshState,
  });

  // Initial state constructor for convenience
  factory RssFeedModel.initial() {
    return const RssFeedModel(
      allFeeds: [],
      loadingStates: LoadingStates.initial,
      refreshState: LoadingStates.initial,
    );
  }

  final List<UrlModel> allFeeds;
  final LoadingStates loadingStates;
  final LoadingStates refreshState;

  RssFeedModel copyWith({
    List<UrlModel>? allFeeds,
    LoadingStates? loadingStates,
    LoadingStates? refreshState,
  }) {
    return RssFeedModel(
      allFeeds: allFeeds ?? this.allFeeds,
      loadingStates: loadingStates ?? this.loadingStates,
      refreshState: refreshState ?? this.refreshState,
    );
  }

  // toString method for easier debugging and logging
  @override
  String toString() {
    return 'RssFeedState(allFeeds: $allFeeds, loadingStates: $loadingStates, refreshState: ,)';
  }

  @override
  List<Object> get props => [
        allFeeds,
        loadingStates,
        refreshState,
      ];
}
