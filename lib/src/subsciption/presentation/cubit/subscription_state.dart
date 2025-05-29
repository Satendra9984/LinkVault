// ignore_for_file: public_member_api_docs

part of 'subscription_cubit.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    required this.loadingStates,
    required this.videoWatchingStates,
    this.globalUser,
  });

  final GlobalUser? globalUser;
  final LoadingStates loadingStates;
  final LoadingStates videoWatchingStates;

  SubscriptionState copyWith({
    LoadingStates? loadingStates,
    LoadingStates? videoWatchingStates,
    GlobalUser? globalUser,
  }) {
    return SubscriptionState(
      loadingStates: loadingStates ?? this.loadingStates,
      videoWatchingStates: videoWatchingStates ?? this.videoWatchingStates,
      globalUser: globalUser ?? this.globalUser,
    );
  }

  @override
  List<Object?> get props => [
        loadingStates,
        videoWatchingStates,
        globalUser,
      ];
}
