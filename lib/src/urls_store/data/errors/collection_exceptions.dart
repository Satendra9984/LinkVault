class CollectionException implements Exception {
  CollectionException({
    required this.statusCode,
    required this.message,
  });

  final String message;
  final int statusCode;
}

class CollectionNotFoundException implements Exception {
  CollectionNotFoundException({
    required this.statusCode,
    required this.message,
  });

  final String message;
  final int statusCode;
}

class CollectionSyncException implements Exception {
  CollectionSyncException({
    required this.statusCode,
    required this.message,
  });

  final String message;
  final int statusCode;
}

class CollectionHierarchyException implements Exception {
  CollectionHierarchyException({
    required this.statusCode,
    required this.message,
  });

  final String message;
  final int statusCode;
}
