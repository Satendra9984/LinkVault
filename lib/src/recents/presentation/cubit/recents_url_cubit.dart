import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_crud_loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';
import 'package:link_vault/core/common/repository_layer/repositories/url_repo_impl.dart';
import 'package:link_vault/core/constants/database_constants.dart';

part 'recents_url_state.dart';

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
          const RecentsUrlState(
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

    // Encode URL to create a Firestore-safe ID
    final newRecentsUrlFirestoreId =
        base64Url.encode(utf8.encode('${urlData.url}#$recents'));

    // Logger.printLog(
    //   '[RECENTS] : newrecentsid: $newRecentsUrlFirestoreId',
    // );

    final urlIndexInRecents = collection.collection!.urls.indexWhere(
      (urlFirestoreIds) {
        // Encode the existing URL in the list to match with the encoded Firestore ID
        final encodedUrlInList =
            urlFirestoreIds; // already encoded do not encode again to compare
        // Logger.printLog(
        //   // ignore: lines_longer_than_80_chars
        //   '[RECENTS] : cmpr $newRecentsUrlFirestoreId $encodedUrlInList, isMatched ${encodedUrlInList == newRecentsUrlFirestoreId}',
        // );
        return encodedUrlInList == newRecentsUrlFirestoreId;
      },
    );

    // Logger.printLog(
    //   '[RECENTS] : ${urlData.firestoreId} already exists $urlIndexInRecents',
    // );

    if (urlIndexInRecents == 0) return;

    if (urlIndexInRecents == -1) {
      final recentUrlData = urlData.copyWith(
        firestoreId: newRecentsUrlFirestoreId,
        collectionId: recentsCollectionId,
        parentUrlModelFirestoreId: urlData.firestoreId,
      );
      await _urlRepoImpl
          .addRecentUrlData(
        urlData: recentUrlData,
        collection: collection.collection!,
        userId: _globalUserCubit.state.globalUser!.id,
      )
          .then(
        (result) async {
          await result.fold(
            (failed) {
              emit(
                state.copyWith(
                  urlCrudLoadingStates: UrlCrudLoadingStates.errorAdding,
                ),
              );
            },
            (response) async {
              final (urlData, updatedCollection) = response;

              _collectionsCubit
                ..updateCollection(
                  updatedCollection: updatedCollection,
                  fetchSubCollIndexAdded: 0,
                )
                ..clearUrlsList(
                  collectionId: updatedCollection.id,
                );

              // Logger.printLog(
              // ignore: lines_longer_than_80_chars
              //   '[RECENTS] : addedurl $newRecentsUrlFirestoreId, ${updatedCollection.id}',
              // );

              emit(
                state.copyWith(
                  urlCrudLoadingStates: UrlCrudLoadingStates.addedSuccessfully,
                ),
              );
            },
          );
        },
      );
    } else {
      // TODO : SOME PROBLEM WITH DELETION
      final urlsList = collection.collection!.urls
        ..removeAt(urlIndexInRecents)
        ..insert(0, urlData.firestoreId);

      if (urlsList.length > 200) {
        urlsList.removeRange(200, urlsList.length);
      }

      final recentUpdatedCollection = collection.collection!.copyWith(
        urls: urlsList,
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
    }
  }
}
