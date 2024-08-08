// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/utils/logger.dart';
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

  // ADD SEARCH FIELDS NOTIFIERS HERE FOR MULTI PAGE CONTROL
  // Define ValueNotifiers for each parameter
  final _formKey = GlobalKey<FormState>();
  final _nameSearchNotifier = TextEditingController();
  final _categoriesNotifier = ValueNotifier<List<String>>([]);
  final _createStartDateNotifier = ValueNotifier<DateTime?>(null);
  final _createEndDateNotifier = ValueNotifier<DateTime?>(null);
  final _updatedStartDateNotifier = ValueNotifier<DateTime?>(null);
  final _updatedEndDateNotifier = ValueNotifier<DateTime?>(null);
  final _isFavouriteNotifier = ValueNotifier<bool?>(null);

  // Getters for each ValueNotifier
  GlobalKey get formKey => _formKey;
  TextEditingController get nameSearch => _nameSearchNotifier;
  ValueNotifier<List<String>> get categories => _categoriesNotifier;
  ValueNotifier<DateTime?> get createStartDate => _createStartDateNotifier;
  ValueNotifier<DateTime?> get createEndDate => _createEndDateNotifier;
  ValueNotifier<DateTime?> get updatedStartDate => _updatedStartDateNotifier;
  ValueNotifier<DateTime?> get updatedEndDate => _updatedEndDateNotifier;
  ValueNotifier<bool?> get isFavourite => _isFavouriteNotifier;

  Future<void> migrateData() async {
    await _searchingRepoImpl.migrateDatabase();
  }

  void clearPrevResults() {
    emit(
      state.copyWith(urls: [], collections: []),
    );
  }

  Future<void> searchDB() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    clearPrevResults();
    await searchLocalDatabaseCollections();
    await searchLocalDatabaseURLs();
  }

  Future<void> searchLocalDatabaseCollections() async {
    final collectionsIndex = state.collections.length;

    createStartDate.value ??= DateTime(2024, 7);
    createEndDate.value ??= DateTime.now();
    updatedStartDate.value ??= DateTime(2024, 7);
    updatedEndDate.value ??= DateTime.now();

    await _searchingRepoImpl
        .searchLocalDatabase(
      pageSize: 28,
      startIndex: collectionsIndex,
      nameSearch: nameSearch.text,
      categories: categories.value,
      createStartDate: createStartDate.value!,
      createEndDate: createEndDate.value!,
      updatedStartDate: updatedStartDate.value!,
      updatedEndDate: updatedEndDate.value!,
    )
        .then(
      (result) {
        result.fold(
          (failed) {},
          (collections) {
            final updatedCollections = [...state.collections, ...collections]
              ..removeWhere(
                (element) {
                  if (element.status == null ||
                      element.status?.containsKey('is_favourite') == false) {
                    return false;
                  }

                  final isFavourite = element.status!['is_favourite'];

                  return isFavourite != _isFavouriteNotifier.value;
                },
              );

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

  Future<void> searchLocalDatabaseURLs() async {
    final urlsIndex = state.urls.length;

    createStartDate.value ??= DateTime(2024, 7);
    createEndDate.value ??= DateTime.now();
    updatedStartDate.value ??= DateTime(2024, 7);
    updatedEndDate.value ??= DateTime.now();

    await _searchingRepoImpl
        .searchLocalURLs(
      pageSize: 28,
      startIndex: urlsIndex,
      nameSearch: nameSearch.text,
      categories: categories.value,
      createStartDate: createStartDate.value!,
      createEndDate: createEndDate.value!,
      updatedStartDate: updatedStartDate.value!,
      updatedEndDate: updatedEndDate.value!,
    )
        .then(
      (result) {
        result.fold(
          (failed) {},
          (urls) {
            final upurls = [...state.urls, ...urls]..removeWhere(
                (element) {
                  if (_isFavouriteNotifier.value == null) {
                    return false;
                  }
                  return element.isFavourite != _isFavouriteNotifier.value;
                },
              );
            // Logger.printLog(
            //   'urls length: ${urls.length}, isFav: ${isFavourite.value}',
            // );
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
