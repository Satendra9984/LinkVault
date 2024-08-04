// always_put_required_named_parameters_first

import 'package:equatable/equatable.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';

class CollectionFetchModel extends Equatable {
  const CollectionFetchModel({
    required this.collectionFetchingState,
    required this.subCollectionFetchedIndex,
    this.collection,
  });
  final CollectionModel? collection;
  final LoadingStates collectionFetchingState;
  final int subCollectionFetchedIndex;

  @override
  List<Object?> get props => [
        collection,
        collectionFetchingState,
        subCollectionFetchedIndex,
      ];

  CollectionFetchModel copyWith({
    CollectionModel? collection,
    LoadingStates? collectionFetchingState,
    int? subCollectionFetchedIndex,
    List<UrlFetchStateModel>? urlList,
  }) {
    return CollectionFetchModel(
      collection: collection ?? this.collection,
      collectionFetchingState:
          collectionFetchingState ?? this.collectionFetchingState,
      subCollectionFetchedIndex:
          subCollectionFetchedIndex ?? this.subCollectionFetchedIndex,
    );
  }
}
