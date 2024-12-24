// always_put_required_named_parameters_first

import 'package:equatable/equatable.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';

class CollectionFetchModel extends Equatable {
  const CollectionFetchModel({
    required this.collectionFetchingState,
    this.collection,
  });
  final CollectionModel? collection;
  final LoadingStates collectionFetchingState;

  @override
  List<Object?> get props => [
        collection,
        collectionFetchingState,
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
    );
  }
}
