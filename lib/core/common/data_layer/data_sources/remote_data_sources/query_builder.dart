import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:isar/isar.dart' as isr;
import 'package:link_vault/core/common/data_layer/isar_db_models/collection_model_isar.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_model_isar.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_filters_model.dart';
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

  static cf.Query<Map<String, dynamic>> buildUrlModelFirestoreQuery({
    required String userId,
    required cf.FirebaseFirestore firestore,
    required UrlModelFilters urlFilter,
  }) {
    cf.Query<Map<String, dynamic>> query = firestore
        .collection(userCollection)
        .doc(userId)
        .collection(urlDataCollection);

    // Filter by specific Firestore ID
    // if (urlFilter.firestoreId != null) {
    //   query = query.where('id', isEqualTo: urlFilter.firestoreId);
    // }

    // Filter by Collection ID
    if (urlFilter.collectionId != null) {
      query = query.where('collection_id', isEqualTo: urlFilter.collectionId);
    }

    // Filter by Title (case-insensitive prefix search)
    if (urlFilter.title != null && urlFilter.title!.isNotEmpty) {
      final searchTitle = urlFilter.title!.toLowerCase();
      final endTitle = searchTitle.substring(0, searchTitle.length - 1) +
          String.fromCharCode(
            searchTitle.codeUnitAt(searchTitle.length - 1) + 1,
          );
      query = query
          .where('title', isGreaterThanOrEqualTo: searchTitle)
          .where('title', isLessThan: endTitle);
    }

    // Filter by URL
    if (urlFilter.url != null) {
      query = query.where('url', isEqualTo: urlFilter.url);
    }

    // Filter by Tag
    if (urlFilter.tag != null) {
      query = query.where('tag', isEqualTo: urlFilter.tag);
    }

    // Filter by Description
    if (urlFilter.description != null) {
      query = query.where('description', isEqualTo: urlFilter.description);
    }

    // Filter by Favourite
    if (urlFilter.isFavourite != null) {
      query = query.where('is_favourite', isEqualTo: urlFilter.isFavourite);
    }

    // Filter by Offline
    if (urlFilter.isOffline != null) {
      query = query.where('is_offline', isEqualTo: urlFilter.isOffline);
    }

    // Filter by updatedAfter Date
    if (urlFilter.updatedAfter != null) {
      query = query.where(
        'updated_at',
        isGreaterThanOrEqualTo: urlFilter.updatedAfter!.toUtc(),
      );
    }

    // Filter by updatedBefore Date
    if (urlFilter.updatedBefore != null) {
      query = query.where(
        'updated_at',
        isLessThanOrEqualTo: urlFilter.updatedBefore!.toUtc(),
      );
    }

    // Add Sorting
    if (urlFilter.sortByNameAsc != null) {
      query = query.orderBy(
        'title',
        descending: !urlFilter.sortByNameAsc!,
      );
    }
    if (urlFilter.sortByDateAsc != null) {
      query = query.orderBy(
        'updated_at',
        descending: !urlFilter.sortByDateAsc!,
      );
    }

    // Add Pagination
    if (urlFilter.limit != null) {
      query = query.limit(urlFilter.limit!);
    }
    if (urlFilter.offset != null) {
      query = query.startAfter([urlFilter.offset]);
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

  static isr.QueryBuilder<UrlModelIsar, UrlModelIsar, isr.QWhere>
      buildUrlModelIsarQuery(
    UrlModelFilters filter,
    isr.IsarCollection<UrlModelIsar> isar,
  ) {
    // Start with the base query
    final query = isar.where();

    // Create a filter builder for additional conditions
    var filterBuilder = query.filter();

    // Apply firestoreId filter
    if (filter.firestoreId?.isNotEmpty ?? false) {
      filterBuilder = filterBuilder.firestoreIdEqualTo(filter.firestoreId!);
    }

    // Apply collectionId filter
    if (filter.collectionId?.isNotEmpty ?? false) {
      filterBuilder = filterBuilder.collectionIdEqualTo(filter.collectionId!);
    }

    // Apply title filter (case-insensitive search)
    if (filter.title?.isNotEmpty ?? false) {
      filterBuilder =
          filterBuilder.titleContains(filter.title!, caseSensitive: false);
    }

    // Apply url filter
    if (filter.url?.isNotEmpty ?? false) {
      filterBuilder =
          filterBuilder.urlContains(filter.url!, caseSensitive: false);
    }

    // Apply description filter
    if (filter.description?.isNotEmpty ?? false) {
      filterBuilder = filterBuilder.descriptionContains(
        filter.description!,
        caseSensitive: false,
      );
    }

    // Apply tag filter
    if (filter.tag?.isNotEmpty ?? false) {
      filterBuilder =
          filterBuilder.tagContains(filter.tag!, caseSensitive: false);
    }

    // Apply isFavourite filter
    if (filter.isFavourite != null) {
      filterBuilder = filterBuilder.isFavouriteEqualTo(filter.isFavourite!);
    }

    // Apply metadata filter
    if (filter.metaData != null && filter.metaData!.isNotEmpty) {
      for (final entry in filter.metaData!.entries) {
        final jsonValue =
            entry.value is String ? '"${entry.value}"' : '${entry.value}';
        filterBuilder =
            filterBuilder.metaDataContains('"${entry.key}":$jsonValue');
      }
    }

    // Apply isOffline filter
    if (filter.isOffline != null) {
      filterBuilder = filterBuilder.isOfflineEqualTo(filter.isOffline!);
    }

    // Apply htmlContent filter
    if (filter.htmlContent?.isNotEmpty ?? false) {
      filterBuilder = filterBuilder.htmlContentContains(
        filter.htmlContent!,
        caseSensitive: false,
      );
    }

    // Apply settings filter
    if (filter.settings != null && filter.settings!.isNotEmpty) {
      for (final entry in filter.settings!.entries) {
        final jsonValue =
            entry.value is String ? '"${entry.value}"' : '${entry.value}';
        filterBuilder =
            filterBuilder.settingsContains('"${entry.key}":$jsonValue');
      }
    }

    // Apply date range filters
    if (filter.updatedAfter != null) {
      filterBuilder = filterBuilder.updatedAtGreaterThan(filter.updatedAfter!);
    }
    if (filter.updatedBefore != null) {
      filterBuilder = filterBuilder.updatedAtLessThan(filter.updatedBefore!);
    }

    // Apply sorting
    if (filter.sortByDateAsc != null) {
      filter.sortByDateAsc!
          ? query.sortByUpdatedAt()
          : query.sortByUpdatedAtDesc();
    }

    if (filter.sortByNameAsc != null) {
      filter.sortByNameAsc! ? query.sortByTitle() : query.sortByTitleDesc();
    }

    // Apply pagination
    if (filter.limit != null) {
      query.limit(filter.limit!);
    }

    if (filter.offset != null) {
      query.offset(filter.offset!);
    }

    return query;
  }
}
