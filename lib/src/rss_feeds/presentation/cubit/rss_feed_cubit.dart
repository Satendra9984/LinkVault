import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/rss_feeds/data/repositories/rss_feed_repo.dart';

part 'rss_feed_state.dart';

class RssFeedCubit extends Cubit<RssFeedState> {
  RssFeedCubit()
      : super(
          const RssFeedState(
            feedCollections: {},
          ),
        );

  final RssFeedRepo _rssFeedRepo = RssFeedRepo();

  void initializeNewFeed({
    required String collectionId,
  }) {
    emit(
      state.copyWith(
        feedCollections: {
          ...state.feedCollections,
          collectionId: RssFeedModel.initial(),
        },
      ),
    );
  }

  void fetchAllRssFeed({
    required String collectionId,
  }) async {
    // [TODO] : Get The Collection from CollectionCubit

    // [TODO] : Get all the urls from CollectionCubit
    // and wait until all of the ursl are fetched
  }
}
