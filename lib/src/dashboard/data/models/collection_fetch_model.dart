// always_put_required_named_parameters_first

import 'package:equatable/equatable.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';

class CollectionFetchModel extends Equatable {
  final CollectionModel? collection;
  final LoadingStates collectionFetchingState;
  final int subCollectionFetchedIndex;

  // final LoadingStates urlFetchMoreState;   // No need explicit urlFetchMoreState as UrlFetchStateModel already handles various states
  final List<UrlFetchStateModel> urlList;

  CollectionFetchModel({
    this.collection,
    required this.collectionFetchingState,
    required this.subCollectionFetchedIndex,
    // required this.urlFetchMoreState,
    required this.urlList,
  });

  @override
  List<Object?> get props => [
        collection,
        collectionFetchingState,
        subCollectionFetchedIndex,
        // urlFetchMoreState,
        urlList,
      ];

  CollectionFetchModel copyWith({
    CollectionModel? collection,
    LoadingStates? subCollectionsFetchingState,
    int? subCollectionFetchedIndex,
    LoadingStates? urlFetchMoreState,
    List<UrlFetchStateModel>? urlList,
  }) {
    return CollectionFetchModel(
      collection: collection ?? this.collection,
      collectionFetchingState:
          subCollectionsFetchingState ?? this.collectionFetchingState,
      subCollectionFetchedIndex:
          subCollectionFetchedIndex ?? this.subCollectionFetchedIndex,
      // urlFetchMoreState: urlFetchMoreState ?? this.urlFetchMoreState,
      urlList: urlList ?? this.urlList,
    );
  }
}
