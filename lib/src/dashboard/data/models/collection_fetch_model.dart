// always_put_required_named_parameters_first

import 'package:equatable/equatable.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';

class CollectionFetchingState extends Equatable {
  final CollectionModel? collection;
  final LoadingStates subCollectionsFetchingState;
  final int subCollectionFetchedIndex;

  // final LoadingStates urlFetchMoreState;   // No need explicit urlFetchMoreState as UrlFetchStateModel already handles various states
  final List<UrlFetchStateModel> urlList;

  CollectionFetchingState({
    this.collection,
    required this.subCollectionsFetchingState,
    required this.subCollectionFetchedIndex,
    // required this.urlFetchMoreState,
    required this.urlList,
  });

  @override
  List<Object?> get props => [
        collection,
        subCollectionsFetchingState,
        subCollectionFetchedIndex,
        // urlFetchMoreState,
        urlList,
      ];

  CollectionFetchingState copyWith({
    CollectionModel? collection,
    LoadingStates? subCollectionsFetchingState,
    int? subCollectionFetchedIndex,
    LoadingStates? urlFetchMoreState,
    List<UrlFetchStateModel>? urlList,
  }) {
    return CollectionFetchingState(
      collection: collection ?? this.collection,
      subCollectionsFetchingState:
          subCollectionsFetchingState ?? this.subCollectionsFetchingState,
      subCollectionFetchedIndex:
          subCollectionFetchedIndex ?? this.subCollectionFetchedIndex,
      // urlFetchMoreState: urlFetchMoreState ?? this.urlFetchMoreState,
      urlList: urlList ?? this.urlList,
    );
  }
}
