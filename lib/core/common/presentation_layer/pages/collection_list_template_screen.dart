import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:lottie/lottie.dart';

class CollectionsListScreenTemplate extends StatefulWidget {
  const CollectionsListScreenTemplate({
    required this.isRootCollection,
    required this.collectionModel,
    required this.showAddCollectionButton,
    required this.onCollectionItemFetchedWidget,
    required this.onAddCollectionPressed,
    required this.appBar,
    this.body,
    super.key,
  });

  final bool isRootCollection;
  final CollectionModel collectionModel;
  final bool showAddCollectionButton;

  final void Function() onAddCollectionPressed;

  final Widget? Function({
    required List<Widget> actions,
    required ValueNotifier<List<CollectionFetchModel>> list,
    required List<Widget> Function(CollectionModel) collectionOptions,
  }) appBar;

  final Widget Function({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required VoidCallback filterList,
  })? body;

  final Widget Function({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required int index,
    required List<Widget> Function(CollectionModel) collectionOptions,
  })? onCollectionItemFetchedWidget;

  @override
  State<CollectionsListScreenTemplate> createState() =>
      _CollectionsListScreenTemplateState();
}

class _CollectionsListScreenTemplateState
    extends State<CollectionsListScreenTemplate> {
  late final ScrollController _scrollController;
  final _showAppBar = ValueNotifier(true);
  final _showFullAddUrlButton = ValueNotifier(true);

  var _previousOffset = 0.0;

  // ADDITIONAL FILTERS
  final _atozFilter = ValueNotifier(false);
  final _ztoaFilter = ValueNotifier(false);
  final _updatedAtLatestFilter = ValueNotifier(false);
  final _updatedAtOldestFilter = ValueNotifier(false);
  final _list =
      ValueNotifier<List<CollectionFetchModel>>(<CollectionFetchModel>[]);

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchMoreCollections();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
    super.initState();
  }

  Future<void> _onScroll() async {
    if (_scrollController.offset > _previousOffset) {
      // _showAppBar.value = false;
      _showFullAddUrlButton.value = false;
    } else if (_scrollController.offset < _previousOffset) {
      // _showAppBar.value = true;
      _showFullAddUrlButton.value = true;
    }
    _previousOffset = _scrollController.offset;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      await _fetchMoreCollections();
    }
  }

  Future<void> _fetchMoreCollections() async {
    // if (widget.collectionModel == null) return;

    final fetchCollection = widget.collectionModel;

    await context.read<CollectionsCubit>().fetchMoreSubCollections(
          collectionId: fetchCollection.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: false,
        );
  }

  void _filterList() {
    // FILTER BY TITLE
    if (_atozFilter.value) {
      _filterAtoZ();
    } else if (_ztoaFilter.value) {
      _filterZtoA();
    }

    // FILTER BY UPDATED AT
    if (_updatedAtLatestFilter.value) {
      _filterUpdatedLatest();
    } else if (_updatedAtOldestFilter.value) {
      _filterUpdateOldest();
    }
  }

  void _filterAtoZ() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.collection == null || b.collection == null) {
            return -1;
          }
          return a.collection!.name.toLowerCase().compareTo(
                b.collection!.name.toLowerCase(),
              );
        },
      );
  }

  void _filterZtoA() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.collection == null || b.collection == null) {
            return -1;
          }
          return b.collection!.name.toLowerCase().compareTo(
                a.collection!.name.toLowerCase(),
              );
        },
      );
  }

  void _filterUpdatedLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.collection == null || b.collection == null) {
            return -1;
          }
          return b.collection!.updatedAt.compareTo(a.collection!.updatedAt);
        },
      );
  }

  void _filterUpdateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.collection == null || b.collection == null) {
            return -1;
          }
          return a.collection!.updatedAt.compareTo(b.collection!.updatedAt);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      appBar: _getAppBar(),
      floatingActionButton: widget.showAddCollectionButton == false
          ? null
          : ValueListenableBuilder(
              valueListenable: _showFullAddUrlButton,
              builder: (context, showFullAddUrlButton, _) {
                return FloatingActionButton.extended(
                  heroTag: '${widget.collectionModel.hashCode}',
                  isExtended: showFullAddUrlButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: ColourPallette.salemgreen,
                  // [DYNAMIC] : THIS IS A DYNAMIC PART
                  onPressed: () => widget.onAddCollectionPressed(),

                  label: showFullAddUrlButton
                      ? const Text(
                          'Collection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColourPallette.white,
                          ),
                        )
                      : const SizedBox.shrink(),
                  icon: const Icon(
                    Icons.create_new_folder_rounded,
                    color: ColourPallette.white,
                  ),
                );
              },
            ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.topLeft,
        child: widget.body != null
            ? widget.body!(
                list: _list,
                filterList: _filterList,
              )
            : BlocConsumer<CollectionsCubit, CollectionsState>(
                listener: (context, state) {},
                builder: (context, state) {
                  final fetchCollection =
                      state.collections[widget.collectionModel.id];

                  if (fetchCollection == null) {
                    return Center(
                      child: SvgPicture.asset(
                        MediaRes.collectionSVG,
                      ),
                    );
                  }

                  final availableSubCollections = <CollectionFetchModel>[];

                  for (var i = 0;
                      i <= fetchCollection.subCollectionFetchedIndex;
                      i++,) {
                    final subCollId =
                        fetchCollection.collection!.subcollections[i];
                    final subCollection = state.collections[subCollId];

                    if (subCollection == null) continue;

                    availableSubCollections.add(subCollection);
                  }

                  if (availableSubCollections.isEmpty) {
                    return Center(
                      child: SvgPicture.asset(
                        MediaRes.collectionSVG,
                      ),
                    );
                  }
                  _list.value = availableSubCollections;

                  _filterList();

                  return ValueListenableBuilder(
                    valueListenable: _list,
                    builder: (context, availableSubCollections, _) {
                      return AlignedGridView.extent(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableSubCollections.length,
                        padding: const EdgeInsets.only(bottom: 120),
                        maxCrossAxisExtent: 80,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 20,
                        itemBuilder: (context, index) {
                          final subCollection = availableSubCollections[index];

                          if (subCollection.collectionFetchingState ==
                              LoadingStates.loading) {
                            return Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  width: 72,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            );
                          } else if (subCollection.collectionFetchingState ==
                              LoadingStates.errorLoading) {
                            return const Icon(
                              Icons.error,
                              color: Colors.red,
                            );
                          }

                          if (widget.onCollectionItemFetchedWidget == null) {
                            return Container();
                          }
                          return widget.onCollectionItemFetchedWidget!(
                            index: index,
                            list: _list,
                            collectionOptions: (collectionModel) =>
                                showCollectionModelOptionsBottomSheet(
                              context,
                              collectionModel: collectionModel,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  PreferredSize _getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showAppBar,
        builder: (context, isVisible, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isVisible ? kToolbarHeight + 16 : 24.0,
            child: widget.appBar(
              list: _list,
              actions: [
                _filterOptions(),
              ],
              collectionOptions: (collectionModel) =>
                  showCollectionModelOptionsBottomSheet(
                context,
                collectionModel: collectionModel,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterOptions() {
    return PopupMenuButton(
      color: ColourPallette.white,
      padding: const EdgeInsets.only(right: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.filter_alt_rounded,
      ),
      itemBuilder: (ctx) {
        return [
          ListFilterPopupMenuItem(
            title: 'A to Z',
            notifier: _atozFilter,
            onPress: () {
              _atozFilter.value = !_atozFilter.value;
              if (_atozFilter.value) {
                _ztoaFilter.value = false;
                _filterAtoZ();
              }
            },
          ),
          ListFilterPopupMenuItem(
            title: 'Z to A',
            notifier: _ztoaFilter,
            onPress: () {
              _ztoaFilter.value = !_ztoaFilter.value;
              if (_ztoaFilter.value) {
                _atozFilter.value = false;
                _filterZtoA();
              }
            },
          ),
          ListFilterPopupMenuItem(
            title: 'Latest First',
            notifier: _updatedAtLatestFilter,
            onPress: () {
              _updatedAtLatestFilter.value = !_updatedAtLatestFilter.value;
              if (_updatedAtLatestFilter.value) {
                _updatedAtOldestFilter.value = false;
                _filterUpdatedLatest();
              }
            },
          ),
          ListFilterPopupMenuItem(
            title: 'Oldest First',
            notifier: _updatedAtOldestFilter,
            onPress: () {
              _updatedAtOldestFilter.value = !_updatedAtOldestFilter.value;
              if (_updatedAtOldestFilter.value) {
                _updatedAtLatestFilter.value = false;
                _filterUpdateOldest();
              }
            },
          ),
        ];
      },
    );
  }

  // FOR THE COLLECTION-MODEL
  List<Widget> showCollectionModelOptionsBottomSheet(
    BuildContext context, {
    required CollectionModel collectionModel,
  }) {
    const titleTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

    final showLastUpdated = ValueNotifier(false);

    return [
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
                onTap: () => showLastUpdated.value = !showLastUpdated.value,
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
              onTap: () => showLastUpdated.value = !showLastUpdated.value,
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
    ];
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


}
