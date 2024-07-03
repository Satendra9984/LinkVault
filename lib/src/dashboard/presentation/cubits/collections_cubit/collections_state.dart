part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({
    required this.collections,
  });


  final Map<String, CollectionModel> collections;
  

  @override
  List<Object> get props => [collections,];
}
