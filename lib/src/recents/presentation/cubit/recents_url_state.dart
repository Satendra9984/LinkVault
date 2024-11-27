part of 'recents_url_cubit.dart';

class RecentsUrlState extends Equatable {
  const RecentsUrlState({
    required this.urlCrudLoadingStates,
  });

  final UrlCrudLoadingStates urlCrudLoadingStates;

  RecentsUrlState copyWith({
    UrlCrudLoadingStates? urlCrudLoadingStates,
  }) {
    return RecentsUrlState(
      urlCrudLoadingStates: urlCrudLoadingStates ?? this.urlCrudLoadingStates,
    );
  }

  @override
  List<Object> get props => [
        urlCrudLoadingStates,
      ];
}

