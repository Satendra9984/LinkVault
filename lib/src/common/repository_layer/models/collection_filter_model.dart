class CollectionFilter {
  final String? name;
  final String? category;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final DateTime? updatedAfter;
  final DateTime? updatedBefore;
  final bool? sortByNameAsc;
  final bool? sortByDateAsc;
  final int? limit;
  final int? offset;

  CollectionFilter({
    this.name,
    this.category,
    this.createdAfter,
    this.createdBefore,
    this.updatedAfter,
    this.updatedBefore,
    this.sortByNameAsc,
    this.sortByDateAsc,
    this.limit,
    this.offset,
  });

  CollectionFilter copyWith({
    String? name,
    String? category,
    DateTime? createdAfter,
    DateTime? createdBefore,
    DateTime? updatedAfter,
    DateTime? updatedBefore,
    bool? sortByNameAsc,
    bool? sortByDateAsc,
    int? limit,
    int? offset,
  }) {
    return CollectionFilter(
      name: name ?? this.name,
      category: category ?? this.category,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      updatedAfter: updatedAfter ?? this.updatedAfter,
      updatedBefore: updatedBefore ?? this.updatedBefore,
      sortByNameAsc: sortByNameAsc ?? this.sortByNameAsc,
      sortByDateAsc: sortByDateAsc ?? this.sortByDateAsc,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
