import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/app_home/presentation/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';

class CollectionsListScreenTemplate extends StatefulWidget {
  const CollectionsListScreenTemplate({
    required this.collectionFetchModel,
    required this.showAddCollectionButton,
    required this.onCollectionItemFetchedWidget,
    required this.onAddCollectionPressed,
    required this.appBar,
    this.body,
    super.key,
  });

  final CollectionFetchModel? collectionFetchModel;
  final bool showAddCollectionButton;

  final void Function() onAddCollectionPressed;

  final Widget? Function({
    required List<Widget> actions,
    required ValueNotifier<List<CollectionFetchModel>> list,
  }) appBar;

  final Widget Function({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required VoidCallback filterList,
  })? body;

  final Widget Function({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required int index,
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
    if (widget.collectionFetchModel == null) return;

    final fetchCollection = widget.collectionFetchModel!;

    await context.read<CollectionsCubit>().fetchMoreSubCollections(
          collectionId: fetchCollection.collection!.id,
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
      floatingActionButton: widget.collectionFetchModel == null ||
              widget.showAddCollectionButton == false
          ? null
          : ValueListenableBuilder(
              valueListenable: _showFullAddUrlButton,
              builder: (context, showFullAddUrlButton, _) {
                return FloatingActionButton.extended(
                  heroTag: '${widget.collectionFetchModel!.hashCode}',
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
                  if (widget.collectionFetchModel == null) {
                    return Container();
                  }

                  final fetchCollection = state
                      .collections[widget.collectionFetchModel!.collection!.id];

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
}
