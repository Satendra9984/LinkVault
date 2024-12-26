class UrlModelFilters {
  final String? firestoreId;
  final String? collectionId;
  final String? title;
  final String? url;
  final String? description;
  final String? tag;
  final bool? isFavourite;
  final Map<String, dynamic>? metaData;
  final bool? isOffline;
  final String? htmlContent;
  final Map<String, dynamic>? settings;
  final DateTime? updatedAfter;
  final DateTime? updatedBefore;
  final bool? sortByNameAsc;
  final bool? sortByDateAsc;
  final int? limit;
  final int? offset;

  UrlModelFilters({
    required this.collectionId,
    this.firestoreId,
    this.title,
    this.url,
    this.description,
    this.tag,
    this.isFavourite,
    this.isOffline,
    this.metaData,
    this.htmlContent,
    this.settings,
    this.updatedAfter,
    this.updatedBefore,
    this.sortByNameAsc,
    this.sortByDateAsc,
    this.limit,
    this.offset,
  });

  /// Create a copy of UrlModelFilters with updated fields
  UrlModelFilters copyWith({
    String? firestoreId,
    String? collectionId,
    String? title,
    String? url,
    String? description,
    String? tag,
    bool? isFavourite,
    Map<String, dynamic>? metaData,
    bool? isOffline,
    String? htmlContent,
    Map<String, dynamic>? settings,
    DateTime? updatedAfter,
    DateTime? updatedBefore,
    bool? sortByNameAsc,
    bool? sortByDateAsc,
    int? limit,
    int? offset,
  }) {
    return UrlModelFilters(
      firestoreId: firestoreId ?? this.firestoreId,
      collectionId: collectionId ?? this.collectionId,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      isFavourite: isFavourite ?? this.isFavourite,
      metaData: metaData ?? this.metaData,
      isOffline: isOffline ?? this.isOffline,
      htmlContent: htmlContent ?? this.htmlContent,
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
      firestoreId != null ||
      collectionId != null ||
      title != null ||
      url != null ||
      description != null ||
      tag != null ||
      isFavourite != null ||
      isOffline != null ||
      metaData != null ||
      htmlContent != null ||
      settings != null ||
      updatedAfter != null ||
      updatedBefore != null ||
      sortByNameAsc != null ||
      sortByDateAsc != null ||
      limit != null ||
      offset != null;

  @override
  String toString() {
    return '''
      UrlModelFilters(
        firestoreId: $firestoreId,
        collectionId: $collectionId,
        title: $title,
        url: $url,
        description: $description,
        tag: $tag,
        isFavourite: $isFavourite,
        isOffline: $isOffline,
        metaData: $metaData,
        htmlContent: $htmlContent,
        settings: $settings,
        updatedAfter: $updatedAfter,
        updatedBefore: $updatedBefore,
        sortByNameAsc: $sortByNameAsc,
        sortByDateAsc: $sortByDateAsc,
        limit: $limit,
        offset: $offset,
      )''';
  }
}
