part of 'url_crud_cubit.dart';

class UrlCrudCubitState extends Equatable {
  const UrlCrudCubitState({
    required this.urlCrudLoadingStates,
  });

  final UrlCrudLoadingStates urlCrudLoadingStates;

  UrlCrudCubitState copyWith({
    UrlCrudLoadingStates? urlCrudLoadingStates,
  }) {
    return UrlCrudCubitState(
      urlCrudLoadingStates: urlCrudLoadingStates ?? this.urlCrudLoadingStates,
    );
  }

  @override
  List<Object> get props => [
        urlCrudLoadingStates,
      ];
}
