import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/list_filter_pop_up_menu_item.dart';

class UrlFaviconListTemplateScreen extends StatefulWidget {
  const UrlFaviconListTemplateScreen({
    required this.collectionModel,
    required this.showAddUrlButton,
    required this.onAddUrlPressed,
    required this.urlsEmptyWidget,
    required this.onUrlModelItemFetchedWidget,
    required this.appBar,
    super.key,
  });

  // final String title;
  final bool showAddUrlButton;
  final CollectionModel collectionModel;

  // Dynamic Widgets
  final void Function({String? url}) onAddUrlPressed;
  final Widget urlsEmptyWidget;

  final Widget Function({
    required ValueNotifier<List<UrlFetchStateModel>> list,
    required int index,
  })? onUrlModelItemFetchedWidget;

  final Widget? Function({
    required ValueNotifier<List<UrlFetchStateModel>> list,
    required List<Widget> actions,
  }) appBar;

  @override
  State<UrlFaviconListTemplateScreen> createState() =>
      _UrlFaviconListTemplateScreenState();
}

class _UrlFaviconListTemplateScreenState
    extends State<UrlFaviconListTemplateScreen> {
  late final ScrollController _scrollController;
  final _showAppBar = ValueNotifier(true);
  final _showFullAddUrlButton = ValueNotifier(true);

  var _previousOffset = 0.0;
  // ADDITIONAL VIEW-HELPER FILTERS
  final _atozFilter = ValueNotifier(false);
  final _ztoaFilter = ValueNotifier(false);
  // final _createdAtLatestFilter = ValueNotifier(false);
  // final _createdAtOldestFilter = ValueNotifier(false);
  final _updatedAtLatestFilter = ValueNotifier(false);
  final _updatedAtOldestFilter = ValueNotifier(false);
  final _list = ValueNotifier<List<UrlFetchStateModel>>(<UrlFetchStateModel>[]);

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
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
      // // Logger.printLog('[scroll] Called on scroll in urlslist');
      _fetchMoreUrls();
    }
  }

  void _fetchMoreUrls() {
    final fetchCollection = widget.collectionModel;

    context.read<CollectionsCubit>().fetchMoreUrls(
          collectionId: fetchCollection.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
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
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return a.urlModel!.title.toLowerCase().compareTo(
                b.urlModel!.title.toLowerCase(),
              );
        },
      );
  }

  void _filterZtoA() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return b.urlModel!.title.toLowerCase().compareTo(
                a.urlModel!.title.toLowerCase(),
              );
        },
      );
  }

  void _filterUpdatedLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return b.urlModel!.updatedAt.compareTo(a.urlModel!.updatedAt);
        },
      );
  }

  void _filterUpdateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return a.urlModel!.updatedAt.compareTo(b.urlModel!.updatedAt);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      floatingActionButton: widget.showAddUrlButton == false
          ? null
          : BlocBuilder<SharedInputsCubit, SharedInputsState>(
              builder: (context, state) {
                if (widget.showAddUrlButton == false) return Container();

                final urls = context.read<SharedInputsCubit>().getUrlsList();

                final url = urls.isNotEmpty ? urls[0] : null;

                return ValueListenableBuilder(
                  valueListenable: _showFullAddUrlButton,
                  builder: (context, showFullAddUrlButton, _) {
                    return FloatingActionButton.extended(
                      key: const ValueKey('extended'),
                      isExtended: showFullAddUrlButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      backgroundColor: ColourPallette.salemgreen,
                      onPressed: () => widget.onAddUrlPressed(url: url),
                      label: showFullAddUrlButton
                          ? const Text(
                              'URL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ColourPallette.white,
                              ),
                            )
                          : const SizedBox.shrink(),
                      icon: const Icon(
                        Icons.add_link_rounded,
                        color: ColourPallette.white,
                      ),
                    );
                  },
                );
              },
            ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final availableUrls =
                state.collectionUrls[widget.collectionModel.id];

            if (availableUrls == null || availableUrls.isEmpty) {
              _fetchMoreUrls();
              // [TODO] : THIS IS DYNAMIC FIELD
              return widget.urlsEmptyWidget;
            }
            _list.value = availableUrls;

            _filterList();
            return ValueListenableBuilder(
              valueListenable: _list,
              builder: (context, availableUrls, _) {
                return AlignedGridView.extent(
                  controller: _scrollController,
                  // physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: availableUrls.length,
                  maxCrossAxisExtent: 80,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  itemBuilder: (context, index) {
                    final url = availableUrls[index];

                    if (url.loadingStates == LoadingStates.loading) {
                      return Center(
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade300,
                          ),
                        ),
                      );
                    } else if (url.loadingStates ==
                        LoadingStates.errorLoading) {
                      return SizedBox(
                        height: 56,
                        width: 56,
                        child: IconButton(
                          onPressed: _fetchMoreUrls,
                          icon: const Icon(
                            Icons.restore,
                            color: ColourPallette.black,
                          ),
                        ),
                      );
                    }

                    if (widget.onUrlModelItemFetchedWidget == null) {
                      return Container();
                    }
                    return widget.onUrlModelItemFetchedWidget!(
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
            // [TODO] : THIS IS DYNAMIC FIELD
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
