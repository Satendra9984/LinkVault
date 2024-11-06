import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_crud_loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';
import 'package:link_vault/core/common/repository_layer/repositories/url_repo_impl.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';

part 'recents_url_state.dart';

// TODO : ADD RECENTS URLS FEATURE
class RecentsUrlCubit extends Cubit<RecentsUrlState> {
  RecentsUrlCubit({
    required CollectionsCubit collectionsCubit,
    required UrlRepoImpl urlRepoImpl,
    required CollectionsRepoImpl collectionRepoImpl,
    required GlobalUserCubit globalUserCubit,
  })  : _urlRepoImpl = urlRepoImpl,
        _collectionsRepoImpl = collectionRepoImpl,
        _collectionsCubit = collectionsCubit,
        _globalUserCubit = globalUserCubit,
        super(
          RecentsUrlState(
            urlCrudLoadingStates: UrlCrudLoadingStates.initial,
          ),
        );

  final UrlRepoImpl _urlRepoImpl;
  final CollectionsRepoImpl _collectionsRepoImpl;
  final CollectionsCubit _collectionsCubit;
  final GlobalUserCubit _globalUserCubit;

  Future<void> addRecentUrl({
    required UrlModel urlData,
  }) async {
    emit(state.copyWith(urlCrudLoadingStates: UrlCrudLoadingStates.adding));

    final recentsCollectionId = _globalUserCubit.getGlobalUser()!.id + recents;

    var collection = _collectionsCubit.getCollection(
      collectionId: recentsCollectionId,
    );

    if (collection == null) {
      await _collectionsCubit.fetchCollection(
        collectionId: recentsCollectionId,
        userId: _globalUserCubit.getGlobalUser()!.id,
        isRootCollection: true,
        collectionName: recents,
      );
    }

    collection = _collectionsCubit.getCollection(
      collectionId: recentsCollectionId,
    );

    if (collection == null || collection.collection == null) {
      return;
    }

    final newRecentsUrlFirestoreId = urlData.firestoreId + recents;

    Logger.printLog(
      '[RECENTS] : $newRecentsUrlFirestoreId, collId $recentsCollectionId ${collection.collection!.urls}',
    );

    final urlIndexInRecents = collection.collection!.urls.indexWhere(
      (url) => url == urlData.firestoreId,
    );
    Logger.printLog(
      '[RECENTS] : ${urlData.firestoreId} already exists $urlIndexInRecents',
    );

    if (urlIndexInRecents == 0) return;

    final recentUrlData = urlData.copyWith(
      firestoreId: newRecentsUrlFirestoreId,
      collectionId: recentsCollectionId,
      parentUrlModelFirestoreId: urlData.firestoreId,
    );

    // CHANGE THE ID TO THE FIRST IT WILL HELP ELIMINATION LEAST
    // USED URLS AS FREQUENTLY USED URLS WILL ALWAYS COMES FIRST
    // LIKE WE CAN STORE 200 URLS TOP AND CAN DELETE REST

    final urlsList = collection.collection!.urls
      ..removeWhere(
        (url) => url == urlData.firestoreId,
      )
      ..insert(0, urlData.firestoreId);

    if (urlsList.length > 200) {
      urlsList.removeRange(200, urlsList.length);
    }

    final recentUpdatedCollection = collection.collection!.copyWith(
      urls: urlsList,
    );

    Logger.printLog(
      '[RECENTS] : $newRecentsUrlFirestoreId adding ${StringUtils.getJsonFormat(recentUpdatedCollection.toJson())}',
    );

    await _collectionsRepoImpl
        .updateSubCollection(
      subCollection: recentUpdatedCollection,
      userId: _globalUserCubit.state.globalUser!.id,
    )
        .then(
      (result) {
        result.fold(
          (failed) {},
          (updatedCollection) {
            Logger.printLog('[RECENTS] : updating ${updatedCollection.id}');

            _collectionsCubit
              ..updateCollection(
                updatedCollection: updatedCollection,
                fetchSubCollIndexAdded: 0,
              )
              ..clearUrlsList(
                collectionId: updatedCollection.id,
              );
          },
        );
      },
    );

    // await _urlRepoImpl
    //     .addRecentUrlData(
    //   urlData: recentUrlData,
    //   collection: collection.collection!,
    //   userId: _globalUserCubit.state.globalUser!.id,
    // )
    //     .then(
    //   (result) async {
    //     await result.fold(
    //       (failed) {
    //         emit(
    //           state.copyWith(
    //             urlCrudLoadingStates: UrlCrudLoadingStates.errorAdding,
    //           ),
    //         );
    //       },
    //       (response) async {
    //         final (urlData, collection) = response;

    //         _collectionsCubit
    //           ..addUrl(url: urlData, collection: collection)
    //           ..updateCollection(
    //             updatedCollection: collection,
    //             fetchSubCollIndexAdded: 0,
    //           );

    //         Logger.printLog(
    //           '[RECENTS] : addedurl ${urlData.firestoreId}, ${collection.id}',
    //         );
    //         emit(
    //           state.copyWith(
    //             urlCrudLoadingStates: UrlCrudLoadingStates.addedSuccessfully,
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }
}
