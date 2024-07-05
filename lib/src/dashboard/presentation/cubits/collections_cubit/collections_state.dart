// ignore_for_file: public_member_api_docs

part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({
    required this.collections,
    required this.currentCollection,
    required this.collectionLoadingStates,
  });

  final Map<String, CollectionModel> collections;
  /// Current Collection Will be use to only change the ui for this current collection
  /// No need to update all nested collection screens
  final String currentCollection;
  final CollectionLoadingStates collectionLoadingStates;

  @override
  List<Object> get props => [
        collections,
        currentCollection,
        collectionLoadingStates,
      ];

  CollectionsState copyWith({
    Map<String, CollectionModel>? collections,
    String? currentCollection,
    CollectionLoadingStates? collectionLoadingStates,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      currentCollection: currentCollection ?? this.currentCollection,
      collectionLoadingStates: collectionLoadingStates ?? this.collectionLoadingStates,
    );
  }
}
