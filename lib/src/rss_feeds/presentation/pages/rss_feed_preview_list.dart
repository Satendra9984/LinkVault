// ignore_for_file: public_member_api_docs

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_textfield.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/app_home/presentation/widgets/filter_popup_menu_button.dart';
import 'package:link_vault/src/app_home/presentation/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:link_vault/src/rss_feeds/presentation/widgets/rss_feed_preview_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RssFeedUrlsPreviewListWidget extends StatefulWidget {
  const RssFeedUrlsPreviewListWidget({
    // required this.title,
    required this.collectionFetchModel,
    required this.showBottomNavBar,
    required this.isRootCollection,
    super.key,
  });

  // final String title;
  final ValueNotifier<bool> showBottomNavBar;
  final bool isRootCollection;
  final CollectionFetchModel collectionFetchModel;

  @override
  State<RssFeedUrlsPreviewListWidget> createState() =>
      _RssFeedUrlsPreviewListWidgetState();
}

class _RssFeedUrlsPreviewListWidgetState
    extends State<RssFeedUrlsPreviewListWidget>
    with AutomaticKeepAliveClientMixin {
  late RssFeedCubit _rssFeedCubit;
  final _showAppBar = ValueNotifier(true);
  final _showSearchFilterBottomSheet = ValueNotifier(false);
  final _searchTextEditingController = TextEditingController();
  final _showDescriptions = ValueNotifier(false);
  final _showBannerImage = ValueNotifier(true);
  final _isSideWays = ValueNotifier(false);

  final _showLatestFirst = ValueNotifier(false);
  final _showOldestFirst = ValueNotifier(false);

  int rebuilds = 0;
  var _previousOffset = 0.0;
  final ScrollController _scrollController = ScrollController();
  final _list = ValueNotifier(<ValueNotifier<UrlModel>>[]);

  // Categories related data
  final _predefinedCategories = ['Title', 'Description', 'WebsiteName'];
  final _selectedCategory = ValueNotifier(<String>[]);

  @override
  void initState() {
    _rssFeedCubit = context.read<RssFeedCubit>();

    context.read<RssFeedCubit>().initializeNewFeed(
          collectionId: widget.collectionFetchModel.collection!.id,
        );
    // Now updating all rss feed from the urls of this collection
    context.read<RssFeedCubit>().getAllRssFeedofCollection(
          collectionId: widget.collectionFetchModel.collection!.id,
        );
    _scrollController.addListener(_onScroll);
    // Scroll down after the first frame
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
    _previousOffset = _scrollController.offset;
  }

  void _onSearch(BuildContext context) {
    final searchText = _searchTextEditingController.text.toLowerCase().trim();
    final feeds = context.read<RssFeedCubit>().getFeedsOfCollection(
          widget.collectionFetchModel.collection!.id,
        );

    if (feeds == null || feeds.allFeeds.isEmpty) return;

    final stateFeeds = feeds.allFeeds;

    // Filter the List
    final newList = stateFeeds
        .where(
          (feed) {
            var contains = false;
            if (feed.metaData == null) return contains;
            final metaData = feed.metaData!;
            for (final field in _selectedCategory.value) {
              // Logger.printLog('field: $field, contains: $contains');
              switch (field) {
                case 'Title':
                  {
                    contains =
                        metaData.title?.toLowerCase().contains(searchText) ??
                            false;
                    break;
                  }
                case 'Description':
                  {
                    contains = metaData.description
                            ?.toLowerCase()
                            .contains(searchText) ??
                        false;
                    break;
                  }
                case 'WebsiteName':
                  {
                    contains = metaData.websiteName
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

  @override
  void dispose() {
    _scrollController.dispose();
    _showAppBar.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

    // _rssFeedCubit.clearCollectionFeed(
    //   collectionId: widget.collectionFetchModel.collection!.id,
    // );
    // Logger.printLog('[rss] : rssfeed preview list disposed');
    super.dispose();
  }

  double getNavigationBarHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // return mediaQuery.viewPadding.bottom;
    final physicalHeight = ui.window.physicalSize.height;
    final devicePixelRatio = ui.window.devicePixelRatio;
    final screenHeight = physicalHeight / devicePixelRatio;

    // Calculate the height of all known system UI elements
    final statusBarHeight = mediaQuery.padding.top;
    // final viewPadding = mediaQuery.viewPadding.vertical;
    // final viewInsets = mediaQuery.viewInsets.vertical;

    // The difference between the screen height and the height of the app's drawable area
    // should give us the navigation bar height
    final calculatedNavBarHeight =
        screenHeight - mediaQuery.size.height - statusBarHeight;

    // Use max to ensure we don't return a negative value
    return max(calculatedNavBarHeight, 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    return Scaffold(
      backgroundColor: ColourPallette.white,
      appBar: _getAppBar(),
      resizeToAvoidBottomInset: true,
      bottomSheet: _getBottomSheet(),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: BlocBuilder<CollectionsCubit, CollectionsState>(
          builder: (context, state) {
            final availableUrls = state
                .collectionUrls[widget.collectionFetchModel.collection!.id];

            final rssFeedNewsWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  MediaRes.rssFeedSVG,
                  width: size.width,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 24),
                const Text(
                  '“ The Feed Curated for You, by You. ”',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );

            if (availableUrls == null || availableUrls.isEmpty) {
              return Center(child: rssFeedNewsWidget);
            }

            final isAllUrlsNotFetched = availableUrls.length !=
                    widget.collectionFetchModel.collection!.urls.length ||
                availableUrls[availableUrls.length - 1].loadingStates ==
                    LoadingStates.loading;

            if (isAllUrlsNotFetched) {
              return Center(
                child: Column(
                  children: [
                    rssFeedNewsWidget,
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(
                      color: ColourPallette.mountainMeadow,
                      backgroundColor: ColourPallette.white,
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<RssFeedCubit, RssFeedState>(
              builder: (context, state) {
                final feeds = state.feedCollections[
                    widget.collectionFetchModel.collection!.id];

                if (feeds == null || feeds.allFeeds.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        rssFeedNewsWidget,
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(
                          color: ColourPallette.mountainMeadow,
                          backgroundColor: ColourPallette.white,
                        ),
                      ],
                    ),
                  );
                }

                _list.value = feeds.allFeeds.map(ValueNotifier.new).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController
                      ..jumpTo(kToolbarHeight + 16)
                      ..jumpTo(kToolbarHeight);
                  }
                });

                // Logger.printLog('cacheExtent: ${size.height * 2}');

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

                            final urlMetaData = url.metaData ??
                                UrlMetaData.isEmpty(title: url.title);
                            return ValueListenableBuilder(
                              valueListenable: _isSideWays,
                              builder: (context, isSideWays, _) {
                                return ValueListenableBuilder(
                                  valueListenable: _showBannerImage,
                                  builder: (context, showBannerImages, _) {
                                    return ValueListenableBuilder(
                                      valueListenable: _showDescriptions,
                                      builder: (context, showDescriptions, _) {
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
                                            key: ValueKey(url.firestoreId),
                                            urlModel: url,
                                            isSidewaysLayout: isSideWays,
                                            showDescription: showDescriptions,
                                            showBannerImage: showBannerImages,
                                            onTap: () async {
                                              final uri = Uri.parse(
                                                url.metaData?.rssFeedUrl ??
                                                    url.url,
                                              );
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri);
                                              }
                                            },
                                            onLongPress: () {
                                              // [TODO] : SHOW MORE OPTIONS
                                            },
                                            updateBannerImage: () async {
                                              // Logger.printLog(
                                              //     '[rss] : inlistview updateBannerImage');
                                              final urlModel = await context
                                                  .read<RssFeedCubit>()
                                                  .updateBannerImagefromRssFeedUrl(
                                                    urlModel: url,
                                                    index: index,
                                                  );

                                              _list.value[index - 1].value =
                                                  urlModel;
                                            },
                                            onShareButtonTap: () {
                                              Logger.printLog(
                                                  StringUtils.getJsonFormat(
                                                      url.metaData?.toJson()));
                                              Share.share(
                                                '${url.metaData?.rssFeedUrl ?? url.url}\n${urlMetaData.title}\n${urlMetaData.description}',
                                              );
                                            },
                                            onMoreVertButtontap: () {},
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
            );
          },
        ),
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

  PreferredSize _getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _showAppBar,
          builder: (context, isVisible, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: isVisible ? kToolbarHeight + 24 : 0,
              child: AppBar(
                surfaceTintColor: ColourPallette.mystic,
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        MediaRes.compassSVG,
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.isRootCollection ? 'My Feeds' : widget.collectionFetchModel.collection?.name}(Preview)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  _refreshFeedButton(),
                  _searchFeedButton(),
                  _layoutFilterOptions(),
                  _filterOptions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _refreshFeedButton() {
    return IconButton(
      onPressed: () {
        final collId = widget.collectionFetchModel.collection!.id;
        context
            .read<RssFeedCubit>()
            .refreshCollectionFeed(collectionId: collId);

        // Navigator.of(context).pop();
      },
      padding: const EdgeInsets.all(8),
      icon: const Icon(Icons.refresh_rounded),
    );
  }

  Widget _searchFeedButton() {
    return BlocBuilder<RssFeedCubit, RssFeedState>(
      builder: (context, state) {
        final feeds =
            state.feedCollections[widget.collectionFetchModel.collection!.id];

        if (feeds == null || feeds.allFeeds.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          onPressed: () {
            _showSearchFilterBottomSheet.value =
                !_showSearchFilterBottomSheet.value;
          },
          padding: const EdgeInsets.all(8),
          icon: const Icon(Icons.search_rounded),
        );
      },
    );
  }

  Widget _filterOptions() {
    return FilterPopupMenuButton(
      icon: Icons.filter_alt_rounded,
      menuItems: [
        ListFilterPopupMenuItem(
          title: 'Latest First',
          notifier: _showLatestFirst,
          onPress: () {
            if (_showLatestFirst.value) return;

            _showLatestFirst.value = true;
            if (_showLatestFirst.value) {
              _showOldestFirst.value = false;
            }

            _list.value = [
              ..._list.value
                ..sort(
                  (u1, u2) => u2.value.createdAt.compareTo(u1.value.createdAt),
                ),
            ];
          },
        ),
        ListFilterPopupMenuItem(
          title: 'Oldest First',
          notifier: _showOldestFirst,
          onPress: () {
            if (_showOldestFirst.value) return;

            _showOldestFirst.value = true;
            if (_showLatestFirst.value) {
              _showLatestFirst.value = false;
            }
            _list.value = [
              ..._list.value
                ..sort(
                  (u1, u2) => u1.value.createdAt.compareTo(u2.value.createdAt),
                ),
            ];
          },
        ),
      ],
    );
  }

  Widget _layoutFilterOptions() {
    return FilterPopupMenuButton(
      icon: Icons.format_shapes_rounded,
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

  @override
  bool get wantKeepAlive => true;
}
