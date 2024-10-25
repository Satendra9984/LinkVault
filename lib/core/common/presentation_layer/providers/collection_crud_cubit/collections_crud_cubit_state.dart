part of 'collections_crud_cubit_cubit.dart';


class CollectionCrudCubitState extends Equatable {
  const CollectionCrudCubitState({
    required this.collectionCrudLoadingStates,
  });

  final CollectionCrudLoadingStates collectionCrudLoadingStates;

  CollectionCrudCubitState copyWith({
    CollectionCrudLoadingStates? collectionCrudLoadingStates,
  }) {
    return CollectionCrudCubitState(
      collectionCrudLoadingStates: collectionCrudLoadingStates ?? this.collectionCrudLoadingStates,
    );
  }

  @override
  List<Object> get props => [
        collectionCrudLoadingStates,
      ];
}
