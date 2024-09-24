import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/collection_icon_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/add_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/update_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard/collection_store_page.dart';

class CollectionsListWidget extends StatefulWidget {
  const CollectionsListWidget({
    required this.collectionFetchModel,
    required this.showAddCollectionButton,
    super.key,
  });

  final CollectionFetchModel collectionFetchModel;
  final bool showAddCollectionButton;
  @override
  State<CollectionsListWidget> createState() => _CollectionsListWidgetState();
}

class _CollectionsListWidgetState extends State<CollectionsListWidget> {
  late final ScrollController _scrollController;
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;

  // ADDITIONAL VIEW-HELPER FILTERS
  final _atozFilter = ValueNotifier(false);
  final _ztoaFilter = ValueNotifier(false);
  final _createdAtLatestFilter = ValueNotifier(false);
  final _createdAtOldestFilter = ValueNotifier(false);
  final _updatedAtLatestFilter = ValueNotifier(false);
  final _updatedAtOldestFilter = ValueNotifier(false);
  final _list =
      ValueNotifier<List<CollectionFetchModel>>(<CollectionFetchModel>[]);

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchMoreCollections();
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
      await _fetchMoreCollections();
    }
  }

  Future<void> _fetchMoreCollections() async {
    final fetchCollection = widget.collectionFetchModel;

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

    // FILTER BY CREATED AT
    if (_createdAtLatestFilter.value) {
      _filterCreateLatest();
    } else if (_createdAtOldestFilter.value) {
      _filterCreateOldest();
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

  void _filterCreateLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.collection == null || b.collection == null) {
            return -1;
          }
          return b.collection!.createdAt.compareTo(a.collection!.createdAt);
        },
      );
  }

  void _filterCreateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.collection == null || b.collection == null) {
            return -1;
          }

          return a.collection!.createdAt.compareTo(b.collection!.createdAt);
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
          : FloatingActionButton.extended(
              heroTag: '${widget.collectionFetchModel.hashCode}',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: ColourPallette.salemgreen,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => AddCollectionPage(
                      parentCollection: widget.collectionFetchModel.collection!,
                    ),
                  ),
                );
              },
              label: const Text(
                'Add Collection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColourPallette.white,
                ),
              ),
              icon: const Icon(
                Icons.create_new_folder_rounded,
                color: ColourPallette.white,
              ),
            ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.topLeft,
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final fetchCollection =
                state.collections[widget.collectionFetchModel.collection!.id];

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
              final subCollId = fetchCollection.collection!.subcollections[i];
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

            // const collectionIconWidth = 96.0;

            return ValueListenableBuilder(
              valueListenable: _list,
              builder: (context, availableSubCollections, _) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  controller: _scrollController,
                  child: Column(
                    children: [
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

                          return FolderIconButton(
                            collection: subCollection.collection!,
                            onDoubleTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => UpdateCollectionPage(
                                    collection: subCollection.collection!,
                                  ),
                                ),
                              );
                            },
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => FolderCollectionPage(
                                    collectionId: subCollection.collection!.id,
                                    isRootCollection: false,
                                  ),
                                ),
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
            child: AppBar(
              surfaceTintColor: ColourPallette.mystic,
              title: Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    MediaRes.compassSVG,
                    height: 18,
                    width: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Feeds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.filter_list,
      ),
      itemBuilder: (ctx) {
        return [
          _listFilterPopUpMenyItem(
            title: 'A to Z',
            notifier: _atozFilter,
            onPress: () {
              if (_atozFilter.value) {
                _ztoaFilter.value = false;
              }
              _filterAtoZ();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Z to A',
            notifier: _ztoaFilter,
            onPress: () {
              if (_ztoaFilter.value) {
                _atozFilter.value = false;
              }
              _filterZtoA();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Latest Created First',
            notifier: _createdAtLatestFilter,
            onPress: () {
              if (_createdAtLatestFilter.value) {
                _createdAtOldestFilter.value = false;
              }
              _filterCreateLatest();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Oldest Created First',
            notifier: _createdAtOldestFilter,
            onPress: () {
              if (_createdAtOldestFilter.value) {
                _createdAtLatestFilter.value = false;
              }
              _filterCreateOldest();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Latest Updated First',
            notifier: _updatedAtLatestFilter,
            onPress: () {
              if (_updatedAtLatestFilter.value) {
                _updatedAtOldestFilter.value = false;
              }

              _filterUpdatedLatest();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Oldest Updated First',
            notifier: _updatedAtOldestFilter,
            onPress: () {
              if (_updatedAtOldestFilter.value) {
                _updatedAtLatestFilter.value = false;
              }
              _filterUpdateOldest();
            },
          ),
        ];
      },
    );
  }

  PopupMenuItem<bool> _listFilterPopUpMenyItem({
    required String title,
    required ValueNotifier<bool> notifier,
    required void Function() onPress,
  }) {
    return PopupMenuItem(
      value: notifier.value,
      onTap: () {},
      enabled: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColourPallette.black,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, isFavorite, child) {
              return Checkbox.adaptive(
                value: isFavorite,
                onChanged: (_) {
                  notifier.value = !notifier.value;
                  onPress();
                },
                activeColor: ColourPallette.salemgreen,
              );
            },
          ),
        ],
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}
