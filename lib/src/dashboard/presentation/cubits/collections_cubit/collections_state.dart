// ignore_for_file: public_member_api_docs

part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({
    required this.collections,
    required this.currentCollection,
    required this.collectionLoadingStates,
    required this.collectionUrls,
  });

  final Map<String, CollectionModel> collections;
  final Map<String, UrlModel> collectionUrls;

  /// Current Collection Will be use to only change the ui for this current collection
  /// No need to update all nested collection screens
  final String currentCollection;
  final CollectionLoadingStates collectionLoadingStates;

  @override
  List<Object> get props => [
        collections,
        currentCollection,
        collectionLoadingStates,
        collectionUrls,
      ];

  CollectionsState copyWith({
    Map<String, CollectionModel>? collections,
    String? currentCollection,
    CollectionLoadingStates? collectionLoadingStates,
    Map<String, UrlModel>? collectionUrls,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      currentCollection: currentCollection ?? this.currentCollection,
      collectionLoadingStates:
          collectionLoadingStates ?? this.collectionLoadingStates,
      collectionUrls: collectionUrls ?? this.collectionUrls,
    );
  }
}
