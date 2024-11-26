import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:link_vault/core/common/presentation_layer/pages/collection_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/collection_icon_button.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_store_screen.dart';
import 'package:link_vault/src/search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:lottie/lottie.dart';

class SearchedCollectionsListWidget extends StatefulWidget {
  const SearchedCollectionsListWidget({
    super.key,
  });

  @override
  State<SearchedCollectionsListWidget> createState() =>
      _SearchedCollectionsListWidgetState();
}

class _SearchedCollectionsListWidgetState
    extends State<SearchedCollectionsListWidget>
    with AutomaticKeepAliveClientMixin {
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;

  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
  }

  Future<void> _onScroll() async {
    if (_scrollController.offset > _previousOffset) {
      _showAppBar.value = false;
      // widget.showBottomBar.value = false;
    } else if (_scrollController.offset < _previousOffset) {
      _showAppBar.value = true;
      // widget.showBottomBar.value = true;
    }
    _previousOffset = _scrollController.offset;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreCollections();
    }
  }

  void _fetchMoreCollections() {
    context.read<AdvanceSearchCubit>().searchLocalDatabaseCollections();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CollectionsListScreenTemplate(
      isRootCollection: false,
      collectionModel: CollectionModel.isEmpty(
        userId: context.read<GlobalUserCubit>().getGlobalUser()?.id ?? 'user',
        name: 'Advance Search',
        parentCollection: 'Advance Search',
        status: {
          'status': 'active',
        },
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      showAddCollectionButton: false,
      onAddCollectionPressed: () {},
      onCollectionItemFetchedWidget: null,
      appBar: _getAppBar,
      body: _getBody,
    );
  }

  Widget _getBody({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required VoidCallback filterList,
  }) {
    return BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
      listener: (context, state) {},
      builder: (context, state) {
        final searchCubit = context.read<AdvanceSearchCubit>();

        if (state.collections.isEmpty) {
          return Center(
            child: SvgPicture.asset(
              MediaRes.collectionSVG,
            ),
          );
        }
        filterList();
        final localList = <CollectionFetchModel>[];

        for (var i = 0; i < localList.length; i++) {
          localList.add(
            CollectionFetchModel(
              collectionFetchingState: LoadingStates.loaded,
              subCollectionFetchedIndex: i,
              collection: state.collections[i],
            ),
          );
        }
        list.value = localList;

        return ValueListenableBuilder(
          valueListenable: list,
          builder: (context, availableSubCollectionsFetch, _) {
            final availableSubCollections = availableSubCollectionsFetch
                .map((ele) => ele.collection)
                .toList();

            if (availableSubCollections.isEmpty) {
              Center(
                child: SvgPicture.asset(
                  MediaRes.collectionSVG,
                ),
              );
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              controller: _scrollController,
              child: Column(
                children: [
                  if (availableSubCollections.isEmpty)
                    Center(
                      child: SvgPicture.asset(
                        MediaRes.collectionSVG,
                      ),
                    )
                  else
                    AlignedGridView.extent(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableSubCollections.length,
                      maxCrossAxisExtent: 80,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 20,
                      itemBuilder: (context, index) {
                        // final fetchCollectionCubit = context.read<CollectionsCubit>();
                        final subCollection = availableSubCollections[index];
                        if (subCollection == null) {
                          return const SizedBox.shrink();
                        }
                        return FolderIconButton(
                          collection: subCollection,
                          onLongPress: () async {
                            await showCollectionModelOptionsBottomSheet(
                              context,
                              collectionModel: subCollection,
                            );
                          },
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => CollectionStorePage(
                                  collectionId: subCollection.id,
                                  isRootCollection: false,
                                  appBarLeadingIcon: SvgPicture.asset(
                                    MediaRes.searchSVG,
                                    height: 16,
                                    width: 16,
                                  ),
                                ),
                              ),
                            ).then(
                              (value) {
                                searchCubit.searchDB();
                              },
                            );
                          },
                        );
                      },
                    ),

                  // BOTTOM HEIGHT SO THAT ALL CONTENT IS VISIBLE
                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _getAppBar({
    required List<Widget> actions,
    required ValueNotifier<List<CollectionFetchModel>> list,
    required List<Widget> Function(CollectionModel) collectionOptions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: const Text(
        'Advance Search',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        ...actions,
      ],
    );
  }

  // FOR THE COLLECTION-MODEL
  Future<void> showCollectionModelOptionsBottomSheet(
    BuildContext context, {
    required CollectionModel collectionModel,
  }) async {
    const titleTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    final size = MediaQuery.of(context).size;

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

    onPop() async {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      Navigator.pop(context);
    }

    final showLastUpdated = ValueNotifier(false);

    await showModalBottomSheet<Widget>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints.loose(
        Size(size.width, size.height * 0.45),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
            const EdgeInsets.only(top: 20, bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          // color: Colors.white,
          color: ColourPallette.mystic.withOpacity(0.25),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      MediaRes.folderSVG,
                      height: 16,
                      width: 16,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      StringUtils.capitalizeEachWord(
                        collectionModel == null
                            ? 'Favourites'
                            : collectionModel.name,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // UPDATE URL
              BottomSheetOption(
                // leadingIcon: Icons.access_time_filled_rounded,
                leadingIcon: Icons.replay_circle_filled_outlined,
                title: const Text('Update', style: titleTextStyle),
                trailing: ValueListenableBuilder(
                  valueListenable: showLastUpdated,
                  builder: (ctx, showLastUpdatedVal, _) {
                    if (!showLastUpdatedVal) {
                      return GestureDetector(
                        onTap: () =>
                            showLastUpdated.value = !showLastUpdated.value,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                      );
                    }

                    final updatedAt = collectionModel.updatedAt;
                    // Format to get hour with am/pm notation
                    final formattedTime = DateFormat('h:mma').format(updatedAt);
                    // Combine with the date
                    final lastSynced =
                        'Last ($formattedTime, ${updatedAt.day}/${updatedAt.month}/${updatedAt.year})';

                    return GestureDetector(
                      onTap: () =>
                          showLastUpdated.value = !showLastUpdated.value,
                      child: Text(
                        lastSynced,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColourPallette.salemgreen.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),

                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => UpdateCollectionTemplateScreen(
                        collection: collectionModel,
                        isRootCollection: false,
                      ),
                    ),
                  ).then(
                    (_) {
                      Navigator.pop(context);
                    },
                  );
                },
              ),

              // SYNC WITH REMOTE DATABASE
              BottomSheetOption(
                leadingIcon: Icons.cloud_sync,
                title: const Text('Sync', style: titleTextStyle),
                onTap: () async {
                  final collCubit = context.read<CollectionCrudCubit>();
                  await Navigator.maybePop(context).then(
                    (_) async {
                      await collCubit
                          .syncCollection(
                            collectionModel: collectionModel,
                            isRootCollection: false,
                          )
                          .then(
                            (_) {},
                          );
                    },
                  );
                },
              ),

              // DELETE URL
              BottomSheetOption(
                leadingIcon: Icons.delete_rounded,
                title: const Text('Delete', style: titleTextStyle),
                onTap: () async {
                  await showDeleteCollectionConfirmationDialog(
                    context,
                    () async {
                      final urlCrudCubit = context.read<CollectionCrudCubit>();

                      await urlCrudCubit.deleteCollection(
                        collection: collectionModel,
                        isRootCollection: false,
                      );
                    },
                    collectionModel: collectionModel,
                  ).then(
                    (_) {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(
      () async {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
      },
    );
  }

  Future<void> showDeleteCollectionConfirmationDialog(
    BuildContext context,
    VoidCallback onConfirm, {
    required CollectionModel? collectionModel,
  }) async {
    await showDialog<Widget>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          backgroundColor: ColourPallette.white,
          shadowColor: ColourPallette.mystic,
          title: Row(
            children: [
              LottieBuilder.asset(
                MediaRes.errorANIMATION,
                height: 28,
                width: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${collectionModel?.name}"?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the confirm callback
              },
              child: Text(
                'DELETE',
                style: TextStyle(
                  color: ColourPallette.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
