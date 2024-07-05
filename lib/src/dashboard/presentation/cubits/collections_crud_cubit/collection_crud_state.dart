part of 'collection_crud_cubit.dart';

sealed class CollectionCrudState extends Equatable {
  const CollectionCrudState();

  @override
  List<Object> get props => [];
}

final class CollectionCrudInitial extends CollectionCrudState {}
