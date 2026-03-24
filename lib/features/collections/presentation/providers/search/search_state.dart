class SearchState {
  final String query;
  final String sortOption;
  final bool showOnlyPrivate;

  const SearchState({
    this.query = '',
    this.sortOption = 'date_added',
    this.showOnlyPrivate = false,
  });

  SearchState copyWith({
    String? query,
    String? sortOption,
    bool? showOnlyPrivate,
  }) {
    return SearchState(
      query: query ?? this.query,
      sortOption: sortOption ?? this.sortOption,
      showOnlyPrivate: showOnlyPrivate ?? this.showOnlyPrivate,
    );
  }
}
