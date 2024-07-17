// always_put_required_named_parameters_first

import 'package:equatable/equatable.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';

class CollectionFetchModel extends Equatable {

  // No need explicit urlFetchMoreState as UrlFetchStateModel already handles various states
  // final LoadingStates urlFetchMoreState;
  // final List<UrlFetchStateModel> urlList;

  const CollectionFetchModel({
    required this.collectionFetchingState, required this.subCollectionFetchedIndex, this.collection,
    // required this.urlFetchMoreState,
    // required this.urlList,
  });
  final CollectionModel? collection;
  final LoadingStates collectionFetchingState;
  final int subCollectionFetchedIndex;

  @override
  List<Object?> get props => [
        collection,
        collectionFetchingState,
        subCollectionFetchedIndex,
        // urlFetchMoreState,
        // urlList,
      ];

  CollectionFetchModel copyWith({
    CollectionModel? collection,
    LoadingStates? collectionFetchingState,
    int? subCollectionFetchedIndex,
    LoadingStates? urlFetchMoreState,
    List<UrlFetchStateModel>? urlList,
  }) {
    return CollectionFetchModel(
      collection: collection ?? this.collection,
      collectionFetchingState:
          collectionFetchingState ?? this.collectionFetchingState,
      subCollectionFetchedIndex:
          subCollectionFetchedIndex ?? this.subCollectionFetchedIndex,
      // urlFetchMoreState: urlFetchMoreState ?? this.urlFetchMoreState,
      // urlList: urlList ?? this.urlList,
    );
  }
}
