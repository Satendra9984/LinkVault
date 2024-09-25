part of 'rss_feed_cubit.dart';

sealed class RssFeedState extends Equatable {
  const RssFeedState();

  @override
  List<Object> get props => [];
}

final class RssFeedInitial extends RssFeedState {}
