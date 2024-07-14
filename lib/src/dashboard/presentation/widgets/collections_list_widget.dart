import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/collection_icon_button.dart';

class CollectionsListWidget extends StatefulWidget {
  const CollectionsListWidget({
    required this.collectionFetchModelNotifier,
    required this.onAddFolderTap,
    required this.onFolderTap,
    required this.onFolderDoubleTap,
    super.key,
  });

  final ValueNotifier<CollectionFetchModel> collectionFetchModelNotifier;
  final void Function() onAddFolderTap;
  final void Function(CollectionModel subCollection) onFolderTap;
  final void Function(CollectionModel subCollection) onFolderDoubleTap;

  @override
  State<CollectionsListWidget> createState() => _CollectionsListWidgetState();
}

class _CollectionsListWidgetState extends State<CollectionsListWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchMoreCollections();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreCollections();
    }
  }

  void _fetchMoreCollections() {
    final fetchCollection = widget.collectionFetchModelNotifier.value;

    if (fetchCollection.collectionFetchingState == LoadingStates.loading) {
      return;
    } else if (fetchCollection.subCollectionFetchedIndex >=
        fetchCollection.collection!.subcollections.length) {
      return;
    }

    final start = fetchCollection.subCollectionFetchedIndex + 1;

    final end = min(
      fetchCollection.subCollectionFetchedIndex + 20,
      fetchCollection.collection!.subcollections.length - 1,
    );

    Logger.printLog(
      '${fetchCollection.subCollectionFetchedIndex}, start: $start, end: $end',
    );

    final subCollectionIds = <String>[];
    if (start > -1 &&
        end < fetchCollection.collection!.subcollections.length &&
        end >= start) {
      subCollectionIds.addAll(
        fetchCollection.collection!.subcollections.sublist(start, end),
      );
    }

    context.read<CollectionsCubit>().fetchMoreSubCollections(
          collectionId: fetchCollection.collection!.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: false,
          end: end,
          subCollectionIds: subCollectionIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    const collectionIconWidth = 80.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        borderRadius: BorderRadius.circular(12),
        color: ColourPallette.mystic.withOpacity(0.5),
      ),
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder(
        valueListenable: widget.collectionFetchModelNotifier,
        builder: (context, fetchCollectionModel, _) {
          final availableSubCollections =
              fetchCollectionModel.subCollectionFetchedIndex <= 0
                  ? 0
                  : fetchCollectionModel.subCollectionFetchedIndex;

          return AlignedGridView.extent(
            controller: _scrollController,
            // physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: availableSubCollections + 1,
            maxCrossAxisExtent: collectionIconWidth,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    _onScroll();
                    // widget.onAddFolderTap();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    // color: Colors.amber,
                    child: Column(
                      children: [
                        Icon(
                          Icons.create_new_folder_outlined,
                          size: 38,
                          color: Colors.grey.shade800,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add',
                          softWrap: true,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              index = index - 1;

              final fetchCollectionCubit = context.read<CollectionsCubit>();
              final subCollection = fetchCollectionCubit.getCollection(
                collectionId:
                    fetchCollectionModel.collection!.subcollections[index],
              )!;

              if (subCollection.collectionFetchingState ==
                  LoadingStates.loading) {
                return const CircularProgressIndicator(
                  backgroundColor: ColourPallette.black,
                );
              } else if (subCollection.collectionFetchingState ==
                  LoadingStates.errorLoading) {
                return const Icon(
                  Icons.error,
                  color: Colors.red,
                );
              }

              return FolderIconButton(
                collection: subCollection.collection!,
                onDoubleTap: () =>
                    widget.onFolderDoubleTap(subCollection.collection!),
                onPress: () => widget.onFolderTap(subCollection.collection!),
              );
            },
          );
        },
      ),
    );
  }
}
