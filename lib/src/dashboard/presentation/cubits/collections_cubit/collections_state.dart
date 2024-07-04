// ignore_for_file: public_member_api_docs

part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({
    required this.collections,
    required this.currentCollection,
    required this.collectionLoadingStates,
  });

  final Map<String, CollectionModel> collections;
  final String currentCollection;
  final CollectionLoadingStates collectionLoadingStates;

  @override
  List<Object> get props => [
        collections,
        currentCollection,
        collectionLoadingStates,
      ];
}
