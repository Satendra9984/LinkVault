import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/src/dashboard/data/enums/url_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';

part 'url_cubit_state.dart';

class UrlCrudCubit extends Cubit<UrlCrudCubitState> {
  UrlCrudCubit({
    required CollectionsCubit collectionsCubit,
    required UrlRepoImpl urlRepoImpl,
    required GlobalUserCubit globalUserCubit,
  })  : _urlRepoImpl = urlRepoImpl,
        _collectionsCubit = collectionsCubit,
        _globalUserCubit = globalUserCubit,
        super(
          const UrlCrudCubitState(
            urlCrudLoadingStates: UrlCrudLoadingStates.initial,
          ),
        );

  final UrlRepoImpl _urlRepoImpl;
  final CollectionsCubit _collectionsCubit;
  final GlobalUserCubit _globalUserCubit;

  void cleanUp() {
    emit(
      state.copyWith(
        urlCrudLoadingStates: UrlCrudLoadingStates.initial,
      ),
    );
  }

  Future<void> addUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.adding));
    final collection = _collectionsCubit.getCollection(
      collectionId: urlData.collectionId,
    );

    await _urlRepoImpl
        .addUrlData(
      collection: collection!.collection!,
      urlData: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
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

  Future<void> updateUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.updating));

    await _urlRepoImpl
        .updateUrl(
      urlData: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
    )
        .then(
      (result) {
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
      },
    );
  }

  Future<void> deleteUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.deleting));

    final collection =
        _collectionsCubit.getCollection(collectionId: urlData.collectionId);

    await _urlRepoImpl
        .deleteUrlData(
      collection: collection!.collection,
      urlData: urlData,
      userId: _globalUserCubit.state.globalUser!.id,
    )
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

            _collectionsCubit.deleteUrl(
              url: urlData,
              collectionModel: collection,
            );

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
