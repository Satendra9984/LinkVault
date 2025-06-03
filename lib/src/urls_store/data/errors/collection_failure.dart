import 'package:link_vault/core/errors/failure.dart';

class CollectionFailure extends Failure {
   CollectionFailure({
    required super.message,
    required super.statusCode,
  });
}

class CollectionNotFoundFailure extends CollectionFailure {
   CollectionNotFoundFailure()
      : super(
          message: 'Collection not found',
          statusCode: 404,
        );
}

class CollectionSyncFailure extends CollectionFailure {
   CollectionSyncFailure({
    required super.message,
    required super.statusCode,
  });
}

class CollectionHierarchyFailure extends CollectionFailure {
   CollectionHierarchyFailure({
    required super.message,
  }) : super(statusCode: 400);
}