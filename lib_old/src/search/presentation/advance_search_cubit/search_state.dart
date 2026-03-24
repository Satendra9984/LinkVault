// ignore_for_file: public_member_api_docs

part of 'search_cubit.dart';

class AdvanceSearchState extends Equatable {
  const AdvanceSearchState({
    required this.collections,
    required this.urls,
  });

  final List<CollectionModel> collections;
  final List<UrlModel> urls;

  // CopyWith method for creating a new instance with some modified properties
  AdvanceSearchState copyWith({
    List<CollectionModel>? collections,
    List<UrlModel>? urls,
  }) {
    return AdvanceSearchState(
      collections: collections ?? this.collections,
      urls: urls ?? this.urls,
    );
  }

  @override
  List<Object> get props => [
        collections,
        urls,
      ];
}
