import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_textfield.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/filter_popup_menu_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/rss_feed_preview_widget.dart';
import 'package:link_vault/core/services/clipboard_service.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlPreviewListTemplateScreen extends StatefulWidget {
  const UrlPreviewListTemplateScreen({
    required this.collectionModel,
    required this.showAddUrlButton,
    required this.onAddUrlPressed,
    required this.urlsEmptyWidget,
    // required this.onUrlModelItemFetchedWidget,
    required this.showBottomNavBar,
    required this.isRootCollection,
    required this.appBar,
    required this.onLongPress,
    this.onBookmarkButtonTap,
    this.body,
    super.key,
  });

  // final String title;
  final bool showAddUrlButton;
  final bool isRootCollection;
  final ValueNotifier<bool> showBottomNavBar;

  final CollectionModel collectionModel;

  // Dynamic Widgets
  final void Function({String? url}) onAddUrlPressed;

  final void Function(
    UrlModel, {
    required List<Widget> urlOptions,
  }) onLongPress;

  final void Function({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required UrlModel url,
  })? onBookmarkButtonTap;

  final Widget urlsEmptyWidget;

  final Widget? Function({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required List<Widget> actions,
  }) appBar;

  final Widget Function({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required VoidCallback filterList,
  })? body;

  @override
  State<UrlPreviewListTemplateScreen> createState() =>
      _UrlPreviewListTemplateScreenState();
}

class _UrlPreviewListTemplateScreenState
    extends State<UrlPreviewListTemplateScreen> {
  final _showAppBar = ValueNotifier(true);
  final _showSearchFilterBottomSheet = ValueNotifier(false);
  final _searchTextEditingController = TextEditingController();
  final _showDescriptions = ValueNotifier(false);
  final _showBannerImage = ValueNotifier(true);
  final _isSideWays = ValueNotifier(true);

  // ADDITIONAL VIEW-HELPER FILTERS
  final _atozFilter = ValueNotifier(false);
  final _ztoaFilter = ValueNotifier(false);

  final _updatedAtLatestFilter = ValueNotifier(false);
  final _updatedAtOldestFilter = ValueNotifier(false);
  int rebuilds = 0;
  var _previousOffset = 0.0;
  final ScrollController _scrollController = ScrollController();
  final _list = ValueNotifier(<ValueNotifier<UrlFetchStateModel>>[]);

  // Categories related data
  final _predefinedCategories = ['Title', 'Description', 'WebsiteName'];
  final _selectedCategory = ValueNotifier(<String>[]);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController
          ..jumpTo(kToolbarHeight + 16)
          ..jumpTo(kToolbarHeight);
      }
    });
    _selectedCategory.value = _predefinedCategories;
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.offset > _previousOffset) {
      if (_scrollController.offset > kToolbarHeight - 8) {
        _showAppBar.value = false;
        widget.showBottomNavBar.value = false;
      }
    } else if (_scrollController.offset <= _previousOffset) {
      _showAppBar.value = true;
      widget.showBottomNavBar.value = true;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // // Logger.printLog('[scroll] Called on scroll in urlslist');
      _fetchMoreUrls();
    }
    _previousOffset = _scrollController.offset;
  }

  void _fetchMoreUrls() {
    final fetchCollection = widget.collectionModel;

    context.read<CollectionsCubit>().fetchMoreUrls(
          collectionId: fetchCollection.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
        );
  }

  void _onSearch(BuildContext context) {
    final searchText = _searchTextEditingController.text.toLowerCase().trim();
    final feeds = context
        .read<CollectionsCubit>()
        .state
        .collectionUrls[widget.collectionModel.id];

    if (feeds == null || feeds.isEmpty) return;

    final stateFeeds = feeds;

    // Filter the List
    final newList = stateFeeds
        .where(
          (ffeed) {
            var contains = false;

            if (ffeed.urlModel == null) return contains;

            final feed = ffeed.urlModel!;

            if (feed.metaData == null) return contains;
            // final metaData = feed.metaData!;
            for (final field in _selectedCategory.value) {
              // // Logger.printLog('field: $field, contains: $contains');
              switch (field) {
                case 'Title':
                  {
                    contains = feed.metaData!.title
                            ?.toLowerCase()
                            .contains(searchText) ??
                        false;
                    break;
                  }
                case 'Description':
                  {
                    contains = feed.metaData!.description
                            ?.toLowerCase()
                            .contains(searchText) ??
                        false;
                    break;
                  }
                case 'WebsiteName':
                  {
                    contains = feed.metaData?.websiteName
                            ?.toLowerCase()
                            .contains(searchText) ??
                        false;
                    break;
                  }
                case '':
                  {
                    contains = true;
                  }
                default:
                  contains = false;
              }
              if (contains) break;
            }
            return contains;
          },
        )
        .map(ValueNotifier.new)
        .toList();

    _list.value = newList;
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
          if (a.value.urlModel == null || b.value.urlModel == null) {
            return -1;
          }
          return a.value.urlModel!.title.toLowerCase().compareTo(
                b.value.urlModel!.title.toLowerCase(),
              );
        },
      );
  }

  void _filterZtoA() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.value.urlModel == null || b.value.urlModel == null) {
            return -1;
          }
          return b.value.urlModel!.title.toLowerCase().compareTo(
                a.value.urlModel!.title.toLowerCase(),
              );
        },
      );
  }

  void _filterUpdatedLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.value.urlModel == null || b.value.urlModel == null) {
            return -1;
          }
          return b.value.urlModel!.updatedAt
              .compareTo(a.value.urlModel!.updatedAt);
        },
      );
  }

  void _filterUpdateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.value.urlModel == null || b.value.urlModel == null) {
            return -1;
          }
          return a.value.urlModel!.updatedAt
              .compareTo(b.value.urlModel!.updatedAt);
        },
      );
  }

  Future<void> onLongPress(
    UrlModel urlModel,
    BuildContext context,
  ) async {
    const titleTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    widget.onLongPress(
      urlModel,
      urlOptions: [
        // SYNC WITH REMOTE DATABASE
        BottomSheetOption(
          leadingIcon: Icons.cloud_sync,
          title: const Text(
            'Sync',
            style: titleTextStyle,
          ),
          onTap: () async {
            // ADD SYNCING FUNCTIONALITY
            final urlCrudCubit = context.read<UrlCrudCubit>();
            Navigator.pop(context);
            await urlCrudCubit.syncUrl(
              urlModel: urlModel,
              isRootCollection: widget.isRootCollection,
            );
            // Add functionality here
          },
        ),

        // COPY TO CLIPBOARD
        BlocBuilder<SharedInputsCubit, SharedInputsState>(
          builder: (ctx, state) {
            final sharedInputCubit = context.read<SharedInputsCubit>();

            final firstCopiedUrl = sharedInputCubit.getTopUrl();

            return BottomSheetOption(
              leadingIcon: Icons.copy_all_rounded,
              title: const Text(
                'Copy Link',
                style: titleTextStyle,
              ),
              trailing: firstCopiedUrl != null && firstCopiedUrl == urlModel.url
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: ColourPallette.salemgreen.withOpacity(
                        0.5,
                      ),
                    )
                  : null,
              onTap: () async {
                await Future.wait(
                  [
                    Future(
                      () async {
                        await ClipboardService.instance.copyText(
                          urlModel.url,
                        );
                      },
                    ),
                    Future(
                      () => sharedInputCubit.addUrlInput(
                        urlModel.url,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),

        // OPEN IN BROWSER
        BottomSheetOption(
          leadingIcon: Icons.open_in_new_rounded,
          title: const Text('Open In Browser', style: titleTextStyle),
          onTap: () async {
            await CustomTabsService.launchUrl(
              url: urlModel.url,
              theme: Theme.of(context),
            );
          },
        ),

        // SHARE THE LINK TO OTHER APPS
        BottomSheetOption(
          leadingIcon: Icons.share,
          title: const Text('Share Link', style: titleTextStyle),
          onTap: () async {
            await Future.wait(
              [
                Share.share(urlModel.url),
                Future(() => Navigator.pop(context)),
              ],
            );
            // Add functionality here
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _getAppBar(),
      bottomSheet: _getBottomSheet(),
      floatingActionButton: widget.showAddUrlButton == false
          ? null
          : BlocBuilder<SharedInputsCubit, SharedInputsState>(
              builder: (context, state) {
                if (widget.showAddUrlButton == false) return Container();

                final urls = context.read<SharedInputsCubit>().getUrlsList();

                final url = urls.isNotEmpty ? urls[0] : null;

                return FloatingActionButton.extended(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: ColourPallette.salemgreen,
                  // [TODO] : THIS IS DYNAMIC FIELD
                  onPressed: () => widget.onAddUrlPressed(url: url),
                  label: const Text(
                    'Add URL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColourPallette.white,
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_link_rounded,
                    color: ColourPallette.white,
                  ),
                );
              },
            ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: widget.body != null
            ? widget.body!(
                list: _list,
                filterList: _filterList,
              )
            : BlocConsumer<CollectionsCubit, CollectionsState>(
                listener: (context, state) {},
                builder: (context, state) {
                  final availableUrls =
                      state.collectionUrls[widget.collectionModel.id];

                  if (availableUrls == null || availableUrls.isEmpty) {
                    _fetchMoreUrls();
                    // [TODO] : THIS IS DYNAMIC FIELD
                    return widget.urlsEmptyWidget;
                  }
                  _list.value = availableUrls.map(ValueNotifier.new).toList();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients &&
                        _previousOffset < kToolbarHeight) {
                      _scrollController
                        ..jumpTo(kToolbarHeight + 16)
                        ..jumpTo(kToolbarHeight);
                    }
                  });

                  _filterList();

                  return ValueListenableBuilder(
                    valueListenable: _list,
                    builder: (context, allLocalFeedsList, _) {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: allLocalFeedsList.length + 2,
                        cacheExtent: size.height * 3,
                        itemBuilder: (ctx, index) {
                          if (index == 0) {
                            return const SizedBox(height: kToolbarHeight);
                          } else if (index > allLocalFeedsList.length) {
                            return const SizedBox(height: 200);
                          }

                          return ValueListenableBuilder(
                            valueListenable: allLocalFeedsList[index - 1],
                            builder: (context, feed, _) {
                              final url = feed;
                              if (url.loadingStates == LoadingStates.loading) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.maxFinite,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: size.width * 0.75,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(32),
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    // const SizedBox(height: 8),
                                    const Divider(),
                                    // const SizedBox(height: 8),
                                  ],
                                );
                              } else if (url.loadingStates ==
                                  LoadingStates.errorLoading) {
                                return IconButton(
                                  onPressed: _fetchMoreUrls,
                                  icon: const Icon(
                                    Icons.restore,
                                    color: ColourPallette.black,
                                  ),
                                );
                              }

                              final urlModel = url.urlModel!;

                              final urlMetaData = urlModel;
                              return ValueListenableBuilder(
                                valueListenable: _isSideWays,
                                builder: (context, isSideWays, _) {
                                  return ValueListenableBuilder(
                                    valueListenable: _showBannerImage,
                                    builder: (context, showBannerImages, _) {
                                      return ValueListenableBuilder(
                                        valueListenable: _showDescriptions,
                                        builder:
                                            (context, showDescriptions, _) {
                                          const titleTextStyle = TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          );
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                            ),
                                            child: RssFeedPreviewWidget(
                                              key: ValueKey(
                                                urlModel.firestoreId,
                                              ),
                                              urlModel: urlModel,
                                              urlPreloadMethod:
                                                  UrlPreloadMethods.httpGet,
                                              isSidewaysLayout: isSideWays,
                                              showDescription: showDescriptions,
                                              showBannerImage: showBannerImages,
                                              updateBannerImage: () {},
                                              onBookmarkButtonTap:
                                                  widget.onBookmarkButtonTap ==
                                                          null
                                                      ? null
                                                      : () {
                                                          widget
                                                              .onBookmarkButtonTap!(
                                                            list: _list,
                                                            url: urlModel,
                                                          );
                                                        },
                                              onTap: () async {
                                                final uri =
                                                    Uri.parse(urlModel.url);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri);
                                                }
                                              },
                                              onLongPress: () => onLongPress(
                                                urlModel,
                                                context,
                                              ),
                                              onShareButtonTap: () {
                                                Share.share(
                                                  '${urlModel.url}\n${urlMetaData.title}\n${urlMetaData.description}',
                                                );
                                              },
                                              onLayoutOptionsButtontap: () {},
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
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
                _searchFeedButton(),
                _layoutFilterOptions(),
                _filterOptions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getBottomSheet() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showSearchFilterBottomSheet,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.showBottomNavBar,
            builder: (context, showBottombar, child) {
              const bottomPadding = 56.0;
              const normalPadding = 20.0;

              return Container(
                padding: EdgeInsets.only(
                  left: normalPadding,
                  right: normalPadding,
                  top: normalPadding,
                  bottom: showBottombar ? normalPadding : bottomPadding,
                ),
                decoration: BoxDecoration(
                  color: ColourPallette.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColourPallette.mountainMeadow
                          .withOpacity(0.24), // Light shadow
                      spreadRadius: 3,
                      blurRadius: 16,
                      offset: const Offset(0, -2), // Shift shadow upwards
                    ),
                  ],
                  border: Border.all(
                    color: ColourPallette.mountainMeadow
                        .withOpacity(0.25), // Subtle border
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Fields',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showSearchFilterBottomSheet.value =
                                !_showSearchFilterBottomSheet.value;
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Predefined Categories Section
                    ValueListenableBuilder(
                      valueListenable: _selectedCategory,
                      builder: (context, selectedCategory, child) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: List.generate(
                            _predefinedCategories.length,
                            (index) {
                              final category = _predefinedCategories[index];
                              final isSelected =
                                  selectedCategory.contains(category);

                              return GestureDetector(
                                onTap: () {
                                  final newList = [..._selectedCategory.value];
                                  if (isSelected) {
                                    newList.remove(category);
                                  } else {
                                    newList.add(category);
                                  }
                                  _selectedCategory.value = newList;
                                  _onSearch(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ColourPallette.mountainMeadow
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? ColourPallette.mountainMeadow
                                          : Colors.grey.shade800,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Search Field Section
                    Row(
                      children: [
                        Expanded(
                          child: CustomCollTextField(
                            controller: _searchTextEditingController,
                            hintText: 'crypto bull run ',
                            onTapOutside: (pointer) async {},
                            onSubmitted: (value) async {},
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _onSearch(context),
                          icon: const Icon(Icons.search_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: ColourPallette.salemgreen,
                          ),
                        ),
                      ],
                    ),
                    // You can add more filter options below if needed.
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _filterOptions() {
    return FilterPopupMenuButton(
      icon: const Icon(
        Icons.filter_alt_rounded,
      ),
      menuItems: [
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
      ],
    );
  }

  Widget _searchFeedButton() {
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        final feeds = state.collectionUrls[widget.collectionModel.id];

        if (feeds == null || feeds.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          onPressed: () {
            _showSearchFilterBottomSheet.value =
                !_showSearchFilterBottomSheet.value;
          },
          // padding: const EdgeInsets.all(8),
          icon: const Icon(Icons.search_rounded),
        );
      },
    );
  }

  Widget _layoutFilterOptions() {
    return FilterPopupMenuButton(
      icon: const Icon(
        Icons.format_shapes_rounded,
        // size: 20,
      ),
      menuItems: [
        ListFilterPopupMenuItem(
          title: 'SideWay Layout',
          notifier: _isSideWays,
          onPress: () => _isSideWays.value = !_isSideWays.value,
        ),
        ListFilterPopupMenuItem(
          title: 'Full Description',
          notifier: _showDescriptions,
          onPress: () => _showDescriptions.value = !_showDescriptions.value,
        ),
        ListFilterPopupMenuItem(
          title: 'Show Images',
          notifier: _showBannerImage,
          onPress: () => _showBannerImage.value = !_showBannerImage.value,
        ),
      ],
    );
  }
}
