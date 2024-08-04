// ignore_for_file: public_member_api_docs

part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({
    required this.collections,
    required this.collectionUrls,
  });

  final Map<String, CollectionFetchModel> collections;
  final Map<String, List<UrlFetchStateModel>> collectionUrls;

  @override
  List<Object> get props => [
        collections,
        collectionUrls,
      ];

  CollectionsState copyWith({
    Map<String, CollectionFetchModel>? collections,
    Map<String, List<UrlFetchStateModel>>? collectionUrls,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      collectionUrls: collectionUrls ?? this.collectionUrls,
    );
  }
}
