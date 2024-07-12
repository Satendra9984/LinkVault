import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/enums/url_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';

part 'url_cubit_state.dart';

class UrlCrudCubit extends Cubit<UrlCrudCubitState> {
  UrlCrudCubit({
    required CollectionsCubit collectionsCubit,
    required UrlRepoImpl urlRepoImpl,
  })  : _urlRepoImpl = urlRepoImpl,
        _collectionsCubit = collectionsCubit,
        super(
          const UrlCrudCubitState(
            urlCrudLoadingStates: UrlCrudLoadingStates.initial,
          ),
        );

  final UrlRepoImpl _urlRepoImpl;
  final CollectionsCubit _collectionsCubit;

  void addUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.adding));
    final collection = _collectionsCubit.getCollection(
      collectionId: urlData.collectionId,
    );

    await _urlRepoImpl
        .addUrlData(
      collection: collection!,
      urlData: urlData,
    )
        .then((result) {
      result.fold(
        (failed) {
          emit(
            state.copyWith(
              urlCrudLoadingStates: UrlCrudLoadingStates.errorAdding,
            ),
          );
        },
        (response) {
          final (urlData, collection) = response;

          _collectionsCubit.addUrl(url: urlData, collection: collection);

          emit(
            state.copyWith(
              urlCrudLoadingStates: UrlCrudLoadingStates.addedSuccessfully,
            ),
          );
        },
      );
    });
  }

  void updateUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.updating));

    await _urlRepoImpl.updateUrl(urlData: urlData).then((result) {
      result.fold(
        (failed) {
          emit(
            state.copyWith(
              urlCrudLoadingStates: UrlCrudLoadingStates.errorupdating,
            ),
          );
        },
        (response) {
          final urlData = response;

          _collectionsCubit.updateUrl(url: urlData);

          emit(
            state.copyWith(
              urlCrudLoadingStates: UrlCrudLoadingStates.updatedSuccessfully,
            ),
          );
        },
      );
    });
  }

  void deleteUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.deleting));

    final collection =
        _collectionsCubit.getCollection(collectionId: urlData.collectionId);

    await _urlRepoImpl
        .deleteUrlData(collection: collection, urlData: urlData)
        .then(
      (result) {
        result.fold(
          (failed) {
            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.errordeleting,
              ),
            );
          },
          (response) {
            final (urlData, collection) = response;

            _collectionsCubit.deleteUrl(url: urlData, collection: collection);

            emit(
              state.copyWith(
                urlCrudLoadingStates: UrlCrudLoadingStates.deletedSuccessfully,
              ),
            );
          },
        );
      },
    );
  }
}
