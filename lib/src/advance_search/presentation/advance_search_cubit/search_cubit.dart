import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/advance_search/repositories/searching_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

part 'search_state.dart';

class AdvanceSearchCubit extends Cubit<AdvanceSearchState> {
  AdvanceSearchCubit({
    required SearchingRepoImpl searchingRepoImpl,
  })  : _searchingRepoImpl = searchingRepoImpl,
        super(
          const AdvanceSearchState(
            collections: [],
            urls: [],
          ),
        );

  final SearchingRepoImpl _searchingRepoImpl;

  Future<void> migrateData() async {
    await _searchingRepoImpl.migrateDatabase();
  }

  void clearPrevResults() {
    emit(
      state.copyWith(urls: [], collections: []),
    );
  }

  Future<void> searchDB({
    required String nameSearch,
    required List<String> categories,
    required DateTime createStartDate,
    required DateTime createEndDate,
    required DateTime updatedStartDate,
    required DateTime updatedEndDate,
  }) async {
    await searchLocalDatabaseCollections(
      nameSearch: nameSearch,
      categories: categories,
      createStartDate: createStartDate,
      createEndDate: createEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
    );

    await searchLocalDatabaseURLs(
      nameSearch: nameSearch,
      categories: categories,
      createStartDate: createStartDate,
      createEndDate: createEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
    );
  }

  Future<void> searchLocalDatabaseCollections({
    required String nameSearch,
    required List<String> categories,
    required DateTime createStartDate,
    required DateTime createEndDate,
    required DateTime updatedStartDate,
    required DateTime updatedEndDate,
  }) async {
    final collectionsIndex = state.collections.length;
    await _searchingRepoImpl
        .searchLocalDatabase(
      pageSize: 28,
      startIndex: collectionsIndex,
      nameSearch: nameSearch,
      categories: categories,
      createStartDate: createStartDate,
      createEndDate: createEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
    )
        .then(
      (result) {
        result.fold(
          (failed) {},
          (collections) {
            final updatedCollections = [...collections, ...state.collections];
            emit(
              state.copyWith(
                collections: updatedCollections,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> searchLocalDatabaseURLs({
    required String nameSearch,
    required List<String> categories,
    required DateTime createStartDate,
    required DateTime createEndDate,
    required DateTime updatedStartDate,
    required DateTime updatedEndDate,
  }) async {
    final urlsIndex = state.urls.length;

    await _searchingRepoImpl
        .searchLocalURLs(
      pageSize: 28,
      startIndex: urlsIndex,
      nameSearch: nameSearch,
      categories: categories,
      createStartDate: createStartDate,
      createEndDate: createEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
    )
        .then(
      (result) {
        result.fold(
          (failed) {},
          (urls) {
            final upurls = [...urls, ...state.urls];
            emit(
              state.copyWith(
                urls: upurls,
              ),
            );
          },
        );
      },
    );
  }
}
