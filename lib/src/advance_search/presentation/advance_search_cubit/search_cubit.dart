import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/advance_search/repositories/searching_repo_impl.dart';

part 'search_state.dart';

class AdvanceSearchCubit extends Cubit<AdvanceSearchState> {
  AdvanceSearchCubit({
    required SearchingRepoImpl searchingRepoImpl,
  })  : _searchingRepoImpl = searchingRepoImpl,
        super(
          AdvanceSearchState(),
        );

  final SearchingRepoImpl _searchingRepoImpl;

  Future<void> migrateData() async {
    await _searchingRepoImpl.migrateDatabase();
  }

  Future<void> searchLocalDatabaseCollections({
    required String nameSearch,
    required List<String> categories,
    required DateTime createStartDate,
    required DateTime createEndDate,
    required DateTime updatedStartDate,
    required DateTime updatedEndDate,
    required int startIndex,
    required int pageSize,
  }) async {
    await _searchingRepoImpl.searchLocalDatabase(
      pageSize: pageSize,
      startIndex: startIndex,
      nameSearch: nameSearch,
      categories: categories,
      createStartDate: createStartDate,
      createEndDate: createEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
    );
  }
}
