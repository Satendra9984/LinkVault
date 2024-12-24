import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:isar/isar.dart' as isr;
import 'package:link_vault/core/common/data_layer/isar_db_models/collection_model_isar.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';

class QueryBuilderHelper {
  QueryBuilderHelper._();

  static cf.Query<Map<String, dynamic>> buildCollectionModelFirestoreQuery({
    required String userId,
    required cf.FirebaseFirestore firestore,
    required CollectionFilter collectionFilter,
  }) {
    cf.Query<Map<String, dynamic>> query = firestore
        .collection(userCollection)
        .doc(userId)
        .collection(folderCollections);

    // Add parent collection  collectionFilter
    query = query.where(
      'parent_collection',
      isEqualTo: collectionFilter.parentCollection,
    );

    //  collectionFilter by name using a case-insensitive prefix search
    if (collectionFilter.name != null && collectionFilter.name!.isNotEmpty) {
      final searchName = collectionFilter.name!.toLowerCase();
      final endName = searchName.substring(0, searchName.length - 1) +
          String.fromCharCode(
            searchName.codeUnitAt(searchName.length - 1) + 1,
          );
      query = query
          .where('name', isGreaterThanOrEqualTo: searchName)
          .where('name', isLessThan: endName);
    }

    //  collectionFilter by category
    if (collectionFilter.category != null) {
      query = query.where('category', isEqualTo: collectionFilter.category);
    }

    // Date range  collectionFilters for updated_at
    if (collectionFilter.updatedAfter != null) {
      query = query.where(
        'updated_at',
        isGreaterThanOrEqualTo: collectionFilter.updatedAfter!.toUtc(),
      );
    }
    if (collectionFilter.updatedBefore != null) {
      query = query.where(
        'updated_at',
        isLessThanOrEqualTo: collectionFilter.updatedBefore!.toUtc(),
      );
    }

    // Add sorting
    if (collectionFilter.sortByNameAsc != null) {
      query = query.orderBy(
        'name',
        descending: !collectionFilter.sortByNameAsc!,
      );
    }
    if (collectionFilter.sortByDateAsc != null) {
      query = query.orderBy(
        'updated_at',
        descending: !collectionFilter.sortByDateAsc!,
      );
    }

    // Add pagination
    if (collectionFilter.limit != null) {
      query = query.limit(collectionFilter.limit!);
    }
    if (collectionFilter.offset != null) {
      query = query.startAfter([collectionFilter.offset]);
    }

    return query;
  }

  static isr.QueryBuilder<CollectionModelIsar, CollectionModelIsar,
      isr.QAfterWhereClause> buildCollectionModelIsarQuery(
    CollectionFilter filter,
    isr.IsarCollection<CollectionModelIsar> isar,
  ) {
    // Start with the base query and first where condition
    final query = isar.where().parentCollectionEqualTo(filter.parentCollection);

    // Create a filter builder for additional conditions
    var filterBuilder = query.filter();

    // Apply name filter if provided
    if (filter.name?.isNotEmpty ?? false) {
      filterBuilder =
          filterBuilder.nameContains(filter.name!, caseSensitive: false);
    }

    // Apply category filter if provided
    if (filter.category?.isNotEmpty ?? false) {
      filterBuilder = filterBuilder.categoryEqualTo(filter.category!);
    }

    // Apply status filter if provided
    if (filter.status?.isNotEmpty ?? false) {
      filterBuilder = filterBuilder.statusEqualTo(filter.status!);
    }

    // Apply date range filters
    if (filter.updatedAfter != null) {
      filterBuilder = filterBuilder.updatedAtGreaterThan(filter.updatedAfter!);
    }
    if (filter.updatedBefore != null) {
      filterBuilder = filterBuilder.updatedAtLessThan(filter.updatedBefore!);
    }

    // Apply settings filter if provided
    if (filter.settings != null && filter.settings!.isNotEmpty) {
      for (final entry in filter.settings!.entries) {
        final jsonValue =
            entry.value is String ? '"${entry.value}"' : '${entry.value}';
        filterBuilder =
            filterBuilder.settingsContains('"${entry.key}":$jsonValue');
      }
    }

    // Apply sorting
    // var sortedQuery = query;
    if (filter.sortByDateAsc != null) {
      filter.sortByDateAsc!
          ? query.sortByUpdatedAt()
          : query.sortByUpdatedAtDesc();
    }

    if (filter.sortByNameAsc != null) {
      filter.sortByNameAsc! ? query.sortByName() : query.sortByNameDesc();
    }

    // Execute the query
    return query;
  }
}
