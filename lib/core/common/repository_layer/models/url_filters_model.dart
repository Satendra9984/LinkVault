class UrlModelFilters {
  final String? name;
  final String? category;
  final String parentCollection;
  final String? status;
  final Map<String, dynamic>? settings;
  final DateTime? updatedAfter;
  final DateTime? updatedBefore;
  final bool? sortByNameAsc;
  final bool? sortByDateAsc;
  final int? limit;
  final int? offset;

  UrlModelFilters({
    required this.parentCollection,
    this.name,
    this.category,
    this.status,
    this.settings,
    this.updatedAfter,
    this.updatedBefore,
    this.sortByNameAsc,
    this.sortByDateAsc,
    this.limit,
    this.offset,
  });

  UrlModelFilters copyWith({
    String? name,
    String? category,
    String? parentCollection,
    String? status,
    Map<String, dynamic>? settings,
    DateTime? updatedAfter,
    DateTime? updatedBefore,
    bool? sortByNameAsc,
    bool? sortByDateAsc,
    int? limit,
    int? offset,
  }) {
    return UrlModelFilters(
      name: name ?? this.name,
      category: category ?? this.category,
      parentCollection: parentCollection ?? this.parentCollection,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      updatedAfter: updatedAfter ?? this.updatedAfter,
      updatedBefore: updatedBefore ?? this.updatedBefore,
      sortByNameAsc: sortByNameAsc ?? this.sortByNameAsc,
      sortByDateAsc: sortByDateAsc ?? this.sortByDateAsc,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  /// Check if any filter is applied
  bool get hasFilters =>
      name != null ||
      category != null ||
      parentCollection != null ||
      status != null ||
      settings != null ||
      updatedAfter != null ||
      updatedBefore != null;
}
