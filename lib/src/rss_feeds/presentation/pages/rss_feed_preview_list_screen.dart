// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_textfield.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/filter_popup_menu_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/network_image_builder_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/rss_feed_preview_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_launch_type.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/filter_constants.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/services/clipboard_service.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/presentation/pages/webview.dart';
import 'package:link_vault/src/rss_feeds/data/constants/rss_feed_constants.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_feed_webview.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

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
    // _rssFeedCubit = context.read<RssFeedCubit>();

    // TODO : THIS IS INITIALIZING IT AGAIN AND AGAIN
    // context.read<RssFeedCubit>().initializeNewFeed(
    //       collectionId: widget.collectionFetchModel.collection!.id,
    //     );
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
    // _initializeAlphaFilter();
    _initializeDateWiseFilter();
    _initializeIsSideWaysLayoutFilter();
    _initializeShowBannerImageLayoutFilter();
    _initializeShowFullDescriptionLayoutFilter();

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

  /// FILTER FOR SORTING URLS IN DATETIME ORDER
  void _initializeDateWiseFilter() {
    // Logger.printLog(StringUtils.getJsonFormat(collectionModel.toJson()));
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;

    try {
      if (collectionModel.settings != null &&
          collectionModel.settings!.containsKey(sortDateWise)) {
        final sortDateWiseValue =
            collectionModel.settings![sortDateWise] as bool?;
        if (sortDateWiseValue == null) {
          return;
        }
        if (sortDateWiseValue) {
          _showLatestFirst.value = true;
        } else {
          _showOldestFirst.value = true;
        }
      }
    } catch (e) {}
  }

  Future<void> _updateDateWiseFilter() async {
    // var sortAlphabatically = _atozFilter.value;
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;
    final updatedAt = DateTime.now().toUtc();

    final settings = collectionModel.settings ?? <String, dynamic>{};

    if (_showLatestFirst.value) {
      settings[sortDateWise] = true;
    } else if (_showOldestFirst.value) {
      settings[sortDateWise] = false;
    } else if (_showLatestFirst.value == false &&
        _showOldestFirst.value == false) {
      settings.remove(sortDateWise);
    }

    final updatedCollection = collectionModel.copyWith(
      updatedAt: updatedAt,
      settings: settings,
    );

    // Logger.printLog(StringUtils.getJsonFormat(updatedCollection.toJson()));

    await context.read<CollectionCrudCubit>().updateCollection(
          collection: updatedCollection,
        );
  }

  /// FILTER FOR SIDEWAYS LAYOUT OPTION
  void _initializeIsSideWaysLayoutFilter() {
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;

    try {
      if (collectionModel.settings != null &&
          collectionModel.settings!.containsKey(isSideWayLayout)) {
        final isSideWayLayoutValue =
            collectionModel.settings![isSideWayLayout] as bool?;
        if (isSideWayLayoutValue == null) {
          return;
        }

        _isSideWays.value = isSideWayLayoutValue;
      }
    } catch (e) {}
  }

  Future<void> _updateIsSideWayLayoutFilter() async {
    // var sortAlphabatically = _atozFilter.value;
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;
    final updatedAt = DateTime.now().toUtc();

    final settings = collectionModel.settings ?? <String, dynamic>{};

    settings[isSideWayLayout] = _isSideWays.value;

    final updatedCollection = collectionModel.copyWith(
      updatedAt: updatedAt,
      settings: settings,
    );

    // Logger.printLog(StringUtils.getJsonFormat(updatedCollection.toJson()));

    await context.read<CollectionCrudCubit>().updateCollection(
          collection: updatedCollection,
        );
  }

  /// FILTER FOR SHOW FULL DESCRIPTION LAYOUT OPTION
  void _initializeShowFullDescriptionLayoutFilter() {
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;
    try {
      if (collectionModel.settings != null &&
          collectionModel.settings!.containsKey(showFullDescription)) {
        final showFullDescriptionLayoutValue =
            collectionModel.settings![showFullDescription] as bool?;
        if (showFullDescriptionLayoutValue == null) {
          return;
        }

        _showDescriptions.value = showFullDescriptionLayoutValue;
      }
    } catch (e) {}
  }

  Future<void> _updateShowFullDescriptionLayoutFilter() async {
    // var sortAlphabatically = _atozFilter.value;
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;
    final updatedAt = DateTime.now().toUtc();

    final settings = collectionModel.settings ?? <String, dynamic>{};

    settings[showFullDescription] = _showDescriptions.value;

    final updatedCollection = collectionModel.copyWith(
      updatedAt: updatedAt,
      settings: settings,
    );

    // Logger.printLog(StringUtils.getJsonFormat(updatedCollection.toJson()));

    await context.read<CollectionCrudCubit>().updateCollection(
          collection: updatedCollection,
        );
  }

  /// FILTER FOR SHOW FULL DESCRIPTION LAYOUT OPTION
  void _initializeShowBannerImageLayoutFilter() {
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;
    try {
      if (collectionModel.settings != null &&
          collectionModel.settings!.containsKey(showBannerImage)) {
        final showBannerImageLayoutValue =
            collectionModel.settings![showBannerImage] as bool?;
        if (showBannerImageLayoutValue == null) {
          return;
        }

        _showBannerImage.value = showBannerImageLayoutValue;
      }
    } catch (e) {}
  }

  Future<void> _updateShowBannerImageLayoutFilter() async {
    // var sortAlphabatically = _atozFilter.value;
    final collectionModel = widget.collectionFetchModel.collection;
    if (collectionModel == null) return;
    final updatedAt = DateTime.now().toUtc();

    final settings = collectionModel.settings ?? <String, dynamic>{};

    settings[showBannerImage] = _showBannerImage.value;

    final updatedCollection = collectionModel.copyWith(
      updatedAt: updatedAt,
      settings: settings,
    );

    // Logger.printLog(StringUtils.getJsonFormat(updatedCollection.toJson()));

    await context.read<CollectionCrudCubit>().updateCollection(
          collection: updatedCollection,
        );
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
              // // Logger.printLog('field: $field, contains: $contains');
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
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.manual,
    //   overlays: [
    //     SystemUiOverlay.bottom,
    //     SystemUiOverlay.top,
    //   ],
    // );

    // _rssFeedCubit.clearCollectionFeed(
    //   collectionId: widget.collectionFetchModel.collection!.id,
    // );
    // Logger.printLog('[rss] : rssfeed preview list disposed');
    super.dispose();
  }

  double getNavigationBarHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // return mediaQuery.viewPadding.bottom;
    final physicalHeight = View.of(context).physicalSize.height;
    final devicePixelRatio = View.of(context).devicePixelRatio;
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

                if (feeds == null ||
                    // feeds.loadingStates == LoadingStates.loading ||
                    feeds.loadingStates == LoadingStates.initial) {
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

                if (feeds.allFeeds.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        rssFeedNewsWidget,
                        const SizedBox(height: 20),
                        if (feeds.loadingStates == LoadingStates.loaded)
                          Text(
                            'No Feed For Now.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ColourPallette.information,
                            ),
                          ),
                        if (feeds.loadingStates == LoadingStates.loading)
                          const CircularProgressIndicator(
                            color: ColourPallette.mountainMeadow,
                            backgroundColor: ColourPallette.white,
                          ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            final collId =
                                widget.collectionFetchModel.collection!.id;
                            context
                                .read<RssFeedCubit>()
                                .refreshCollectionFeed(collectionId: collId);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Refresh',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ColourPallette.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.refresh_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final rssFeedCubit = context.read<RssFeedCubit>();

                _list.value = feeds.allFeeds.map(ValueNotifier.new).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients &&
                      _previousOffset < kToolbarHeight) {
                    _scrollController
                      ..jumpTo(kToolbarHeight + 16)
                      ..jumpTo(kToolbarHeight);
                  }
                });

                return ValueListenableBuilder(
                  valueListenable: _list,
                  builder: (context, allLocalFeedsList, _) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: allLocalFeedsList.length + 2,
                      cacheExtent: size.height * 2,
                      itemBuilder: (ctx, index) {
                        if (index == 0) {
                          return const SizedBox(height: kToolbarHeight);
                        } else if (index > allLocalFeedsList.length) {
                          return feeds.loadingStates == LoadingStates.loading
                              ? const CircularProgressIndicator(
                                  color: ColourPallette.mountainMeadow,
                                  backgroundColor: ColourPallette.white,
                                )
                              : const SizedBox(height: 200);
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
                                                color: Colors.grey.shade100,
                                              ),
                                            ),
                                          ),
                                          child: RssFeedPreviewWidget(
                                            key: ValueKey(url.firestoreId),
                                            urlModel: url,
                                            urlPreloadMethod:
                                                UrlPreloadMethods.mayLaunchUrl,
                                            isSidewaysLayout: isSideWays,
                                            showDescription: showDescriptions,
                                            showBannerImage: showBannerImages,
                                            onBookmarkButtonTap: () async {
                                              final urlModelDataForBookmark =
                                                  url.copyWith(
                                                collectionId: widget
                                                        .collectionFetchModel
                                                        .collection!
                                                        .id +
                                                    savedFeeds,
                                                isOffline: !url.isOffline,
                                                url: url.metaData?.rssFeedUrl,
                                              );

                                              if (urlModelDataForBookmark
                                                      .isOffline ==
                                                  false) {
                                                /// TOO COMPLEX DELETE FROM SAVED FEEDS
                                                /// USERS WILL DIRECTLY DELETE FROM
                                                /// SAVEDFEEDS

                                                // await context
                                                //     .read<UrlCrudCubit>()
                                                //     .deleteUrl(
                                                //       urlData:
                                                //           urlModelDataForBookmark,
                                                //           isRootCollection: widget.isRootCollection,
                                                //     );
                                                return;
                                              } else {
                                                await context
                                                    .read<UrlCrudCubit>()
                                                    .addUrl(
                                                      urlData:
                                                          urlModelDataForBookmark,
                                                      isRootCollection: widget
                                                          .isRootCollection,
                                                    );
                                              }

                                              await rssFeedCubit.updateRSSFeed(
                                                feedUrlModel:
                                                    urlModelDataForBookmark
                                                        .copyWith(
                                                  collectionId: widget
                                                      .collectionFetchModel
                                                      .collection!
                                                      .id,
                                                ),
                                              );

                                              final indexB =
                                                  _list.value.indexWhere(
                                                (feed) => feed.value == url,
                                              );

                                              if (indexB < 0) return;

                                              _list.value[indexB].value =
                                                  urlModelDataForBookmark;
                                            },
                                            onTap: () async {
                                              final urlModel = url;
                                              final urlLaunchTypeLocalNotifier =
                                                  ValueNotifier(
                                                UrlLaunchType.customTabs,
                                              );

                                              if (urlModel.settings != null &&
                                                  urlModel.settings!
                                                      .containsKey(
                                                    feedUrlLaunchType,
                                                  )) {
                                                urlLaunchTypeLocalNotifier
                                                        .value =
                                                    UrlLaunchType.fromString(
                                                  urlModel.settings![
                                                          feedUrlLaunchType]
                                                      .toString(),
                                                );
                                              }
                                              switch (urlLaunchTypeLocalNotifier
                                                  .value) {
                                                case UrlLaunchType.customTabs:
                                                  {
                                                    final theme =
                                                        Theme.of(context);
                                                    await CustomTabsService
                                                        .launchUrl(
                                                      url: urlModel.metaData
                                                              ?.rssFeedUrl ??
                                                          urlModel.url,
                                                      theme: theme,
                                                    ).then(
                                                      (_) async {
                                                        // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                                        // JUST LIKE APPS IN BACKGROUND TYPE
                                                      },
                                                    );
                                                    break;
                                                  }
                                                case UrlLaunchType.webView:
                                                  {
                                                    await Navigator.of(context)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            DashboardWebView(
                                                          url: urlModel.metaData
                                                                  ?.rssFeedUrl ??
                                                              urlModel.url,
                                                        ),
                                                      ),
                                                    );

                                                    break;
                                                  }
                                                case UrlLaunchType.readingMode:
                                                  {
                                                    await Navigator.of(context)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            RSSFeedWebView(
                                                          url: urlModel.metaData
                                                                  ?.rssFeedUrl ??
                                                              urlModel.url,
                                                        ),
                                                      ),
                                                    );

                                                    break;
                                                  }
                                                case UrlLaunchType
                                                      .separateBrowserWindow:
                                                  {
                                                    final theme =
                                                        Theme.of(context);
                                                    await CustomTabsService
                                                        .launchUrl(
                                                      url: urlModel.metaData
                                                              ?.rssFeedUrl ??
                                                          urlModel.url,
                                                      theme: theme,
                                                    ).then(
                                                      (_) async {
                                                        // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                                        // JUST LIKE APPS IN BACKGROUND TYPE
                                                      },
                                                    );
                                                    break;
                                                  }
                                              }
                                            },
                                            onLongPress: () async {
                                              // SHOW MORE OPTIONS
                                              final urlc = url.copyWith(
                                                metaData: urlMetaData,
                                              );

                                              await showUrlOptionsBottomSheet(
                                                context,
                                                urlModel: urlc,
                                                urlOptions: [],
                                              );
                                            },
                                            updateBannerImage: () async {
                                              final urlModel = await context
                                                  .read<RssFeedCubit>()
                                                  .updateBannerImagefromRssFeedUrl(
                                                    urlModel: url,
                                                    index: index,
                                                  );

                                              final indexB =
                                                  _list.value.indexWhere(
                                                (feed) => feed.value == url,
                                              );

                                              if (indexB < 0) return;

                                              _list.value[indexB].value =
                                                  urlModel;
                                            },
                                            onShareButtonTap: () {
                                              Share.share(
                                                '${url.metaData?.rssFeedUrl ?? url.url}\n${urlMetaData.title}\n${urlMetaData.description}',
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
              duration: const Duration(milliseconds: 300),
              height: isVisible ? kToolbarHeight + 24 : 0,
              child: AppBar(
                clipBehavior: Clip.none,
                surfaceTintColor: ColourPallette.mystic,
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // SvgPicture.asset(
                      //   MediaRes.compassSVG,
                      //   height: 18,
                      //   width: 18,
                      // ),
                      // const SizedBox(width: 8),
                      Text(
                        widget.collectionFetchModel.collection?.name ??
                            'My Feeds',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // _refreshFeedButton(),
                  _searchFeedButton(),
                  _layoutFilterOptions(),
                  // _feedSettingsButton(),
                  _filterOptions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _feedSettingsButton() {
    return PopupMenuItem(
      value: 'FeedSettings',
      onTap: () {
        // TODO : NAVIGATE TO FEED LAYOUT SETTINGS PAGE
      },
      child: BlocBuilder<RssFeedCubit, RssFeedState>(
        builder: (context, state) {
          const Widget loadingIcon = Icon(Icons.settings_rounded);
          return const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColourPallette.black,
                ),
              ),
              loadingIcon,
            ],
          );
        },
      ),
    );
  }

  PopupMenuItem<String> _refreshFeedButton() {
    return PopupMenuItem(
      value: 'Refresh',
      onTap: () {
        final collId = widget.collectionFetchModel.collection!.id;
        context
            .read<RssFeedCubit>()
            .refreshCollectionFeed(collectionId: collId);
      },
      child: BlocBuilder<RssFeedCubit, RssFeedState>(
        builder: (context, state) {
          const Widget loadingIcon = Icon(Icons.refresh_rounded);
          return const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColourPallette.black,
                ),
              ),
              loadingIcon,
            ],
          );
        },
      ),
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
      icon: const Icon(
        Icons.filter_alt_rounded,
        size: 20,
      ),
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

            _updateDateWiseFilter();
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
            _updateDateWiseFilter();
          },
        ),
        _refreshFeedButton(),
      ],
    );
  }

  Widget _layoutFilterOptions() {
    return FilterPopupMenuButton(
      icon: const Icon(
        Icons.format_shapes_rounded,
        size: 20,
      ),
      menuItems: [
        ListFilterPopupMenuItem(
          title: 'SideWay Layout',
          notifier: _isSideWays,
          onPress: () {
            _isSideWays.value = !_isSideWays.value;
            _updateIsSideWayLayoutFilter();
          },
        ),
        ListFilterPopupMenuItem(
          title: 'Full Description',
          notifier: _showDescriptions,
          onPress: () {
            _showDescriptions.value = !_showDescriptions.value;
            _updateShowFullDescriptionLayoutFilter();
          },
        ),
        ListFilterPopupMenuItem(
          title: 'Show Images',
          notifier: _showBannerImage,
          onPress: () {
            _showBannerImage.value = !_showBannerImage.value;
            _updateShowBannerImageLayoutFilter();
          },
        ),
        // _feedSettingsButton(),
      ],
    );
  }

  Future<void> showUrlOptionsBottomSheet(
    BuildContext context, {
    required UrlModel urlModel,
    required List<Widget> urlOptions,
  }) async {
    // Logger.printLog('showUrlOptionsBottomSheet, ${urlModel.title}');
    // debugPrint(urlModel.title);

    final size = MediaQuery.of(context).size;
    const titleTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

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

    // final showLastUpdated = ValueNotifier(false);
    final urlLaunchTypeLocalNotifier = ValueNotifier(UrlLaunchType.customTabs);

    // final urlModel = url.urlModel!;
    // Logger.printLog(StringUtils.getJsonFormat(urlModel.toJson()));

    if (urlModel.settings != null &&
        urlModel.settings!.containsKey(feedUrlLaunchType)) {
      urlLaunchTypeLocalNotifier.value = UrlLaunchType.fromString(
        urlModel.settings![feedUrlLaunchType].toString(),
      );
    }
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
                    Builder(
                      builder: (context) {
                        final urlModelData = urlModel;
                        final urlMetaData = urlModel.metaData!;

                        var name = '';

                        if (urlModelData.title.isNotEmpty) {
                          name = urlModelData.title;
                        } else if (urlMetaData.title != null &&
                            urlMetaData.title!.isNotEmpty) {
                          name = urlMetaData.title!;
                        } else if (urlMetaData.websiteName != null &&
                            urlMetaData.websiteName!.isNotEmpty) {
                          name = urlMetaData.websiteName!;
                        }

                        final placeHolder = Container(
                          padding: const EdgeInsets.all(2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: ColourPallette.black,
                            // color: Colors.deepPurple
                          ),
                          child: Text(
                            _websiteName(name, 5),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              color: ColourPallette.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 8,
                            ),
                          ),
                        );

                        if (urlModel.metaData?.faviconUrl == null) {
                          return placeHolder;
                        }
                        final metaData = urlModel.metaData;

                        if (metaData?.faviconUrl != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: NetworkImageBuilderWidget(
                                  imageUrl: urlMetaData.faviconUrl!,
                                  compressImage: false,
                                  errorWidgetBuilder: () {
                                    return placeHolder;
                                  },
                                  successWidgetBuilder: (imageData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Builder(
                                        builder: (ctx) {
                                          final memoryImage = Image.memory(
                                            imageData.imageBytesData!,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, _, __) {
                                              return placeHolder;
                                            },
                                          );
                                          // Check if the URL ends with ".svg" to use SvgPicture or Image accordingly
                                          if (urlMetaData.faviconUrl!
                                              .toLowerCase()
                                              .endsWith('.svg')) {
                                            // Try loading the SVG and handle errors
                                            return FutureBuilder(
                                              future: _loadSvgBytes(
                                                imageData.imageBytesData!,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return memoryImage;
                                                } else {
                                                  return snapshot.data!;
                                                }
                                              },
                                            );
                                          } else {
                                            return memoryImage;
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        } else {
                          return placeHolder;
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              StringUtils.capitalizeEachWord(
                                urlModel.metaData?.title ?? urlModel.title,
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ...urlOptions,

              // SAVE THE FEED
              BottomSheetOption(
                leadingIcon: Icons.bookmark,
                title: const Text('Save', style: titleTextStyle),
                trailing: Builder(
                  builder: (ctx) {
                    if (urlModel.isOffline == false) {
                      return const SizedBox.shrink();
                    }

                    return Icon(
                      Icons.check_circle_rounded,
                      color: ColourPallette.salemgreen.withOpacity(0.5),
                    );
                  },
                ),
                onTap: () async {
                  final rssFeedCubit = context.read<RssFeedCubit>();

                  final urlModelDataForBookmark = urlModel.copyWith(
                    collectionId:
                        widget.collectionFetchModel.collection!.id + savedFeeds,
                    isOffline: !urlModel.isOffline,
                    url: urlModel.metaData?.rssFeedUrl,
                  );

                  if (urlModelDataForBookmark.isOffline == false) {
                    /// TOO COMPLEX DELETE FROM SAVED FEEDS
                    /// USERS WILL DIRECTLY DELETE FROM
                    /// SAVEDFEEDS

                    // await context
                    //     .read<UrlCrudCubit>()
                    //     .deleteUrl(
                    //       urlData:
                    //           urlModelDataForBookmark,
                    //           isRootCollection: widget.isRootCollection,
                    //     );
                    return;
                  } else {
                    await context.read<UrlCrudCubit>().addUrl(
                          urlData: urlModelDataForBookmark,
                          isRootCollection: widget.isRootCollection,
                        );
                  }

                  await rssFeedCubit.updateRSSFeed(
                    feedUrlModel: urlModelDataForBookmark.copyWith(
                      collectionId: widget.collectionFetchModel.collection!.id,
                    ),
                  );

                  final indexB = _list.value.indexWhere(
                    (feed) => feed.value == urlModel,
                  );

                  if (indexB < 0) return;

                  _list.value[indexB].value = urlModelDataForBookmark;
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
                    trailing: firstCopiedUrl != null &&
                            firstCopiedUrl == urlModel.url
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: ColourPallette.salemgreen.withOpacity(0.5),
                          )
                        : null,
                    onTap: () async {
                      await Future.wait(
                        [
                          Future(
                            () async {
                              await ClipboardService.instance.copyText(
                                urlModel.metaData?.rssFeedUrl ?? urlModel.url,
                              );
                            },
                          ),
                          Future(
                            () => sharedInputCubit.addUrlInput(
                              urlModel.metaData?.rssFeedUrl ?? urlModel.url,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              // OPEN RSS FEED URL IN DIFFERENT TYPES
              ValueListenableBuilder(
                valueListenable: urlLaunchTypeLocalNotifier,
                builder: (ctx, urlLaunchType, _) {
                  return BottomSheetOption(
                    leadingIcon: Icons.open_in_new_rounded,
                    title: const Text(
                      'Open In',
                      style: titleTextStyle,
                    ),
                    trailing: // DROPDOWN OF BROWSER, WEBVIEW
                        DropdownButton<UrlLaunchType>(
                      value: urlLaunchType,
                      onChanged: (urlLaunchType) {
                        if (urlLaunchType == null) return;
                        urlLaunchTypeLocalNotifier.value = urlLaunchType;
                      },
                      isDense: true,
                      iconEnabledColor: ColourPallette.black,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      underline: const SizedBox.shrink(),
                      dropdownColor: ColourPallette.mystic,
                      items: [
                        ...UrlLaunchType.values.map(
                          (urlLaunchType) => DropdownMenuItem(
                            value: urlLaunchType,
                            child: Text(
                              StringUtils.capitalize(
                                urlLaunchType ==
                                        UrlLaunchType.separateBrowserWindow
                                    ? 'Browser'
                                    : urlLaunchType
                                        .label, // UrlLaunchType.customTabs.label,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      switch (urlLaunchType) {
                        case UrlLaunchType.customTabs:
                          {
                            final theme = Theme.of(context);
                            await CustomTabsService.launchUrl(
                              url: urlModel.url,
                              theme: theme,
                            ).then(
                              (_) async {
                                // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                // JUST LIKE APPS IN BACKGROUND TYPE
                              },
                            );
                            break;
                          }
                        case UrlLaunchType.webView:
                          {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => DashboardWebView(
                                  url: urlModel.metaData?.rssFeedUrl ??
                                      urlModel.url,
                                ),
                              ),
                            );

                            break;
                          }
                        case UrlLaunchType.readingMode:
                          {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => RSSFeedWebView(
                                  url: urlModel.metaData?.rssFeedUrl ??
                                      urlModel.url,
                                ),
                              ),
                            );

                            break;
                          }
                        case UrlLaunchType.separateBrowserWindow:
                          {
                            final theme = Theme.of(context);
                            await CustomTabsService.launchUrl(
                              url:
                                  urlModel.metaData?.rssFeedUrl ?? urlModel.url,
                              theme: theme,
                            ).then(
                              (_) async {
                                // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                // JUST LIKE APPS IN BACKGROUND TYPE
                              },
                            );
                            break;
                          }
                      }

                      await Navigator.maybePop(context);
                    },
                  );
                },
              ),

              // OPEN RSS FEED URL IN WEBVIEW
              // BottomSheetOption(
              //   leadingIcon: Icons.open_in_new_rounded,
              //   title: const Text(
              //     'Open WebView(beta)',
              //     style: titleTextStyle,
              //   ),
              //   onTap: () async {
              //     await Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (ctx) => DashboardWebView(
              //           url: urlModel.url,
              //         ),
              //       ),
              //     ).then(
              //       (_) async {
              //         await Navigator.maybePop(context);
              //       },
              //     );
              //   },
              // ),

              // SHARE THE LINK TO OTHER APPS
              BottomSheetOption(
                leadingIcon: Icons.share,
                title: const Text('Share Link', style: titleTextStyle),
                onTap: () async {
                  await Future.wait(
                    [
                      Share.share(
                        urlModel.metaData?.rssFeedUrl ?? urlModel.url,
                      ),
                      Future(() => Navigator.maybePop(context)),
                    ],
                  );
                  // Add functionality here
                },
              ),

              // DELETE URL
              // BottomSheetOption(
              //   leadingIcon: Icons.delete_rounded,
              //   title: const Text('Delete', style: titleTextStyle),
              //   onTap: () async {
              //     await showDeleteConfirmationDialog(
              //       context,
              //       urlModel,
              //       () => context.read<UrlCrudCubit>().deleteUrl(
              //             urlData: urlModel,
              //             isRootCollection: widget.isRootCollection,
              //           ),
              //     ).then(
              //       (_) {
              //         Navigator.maybePop(context);
              //       },
              //     );
              //   },
              // ),
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

  Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    UrlModel urlModel,
    VoidCallback onConfirm,
  ) async {
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
            'Are you sure you want to delete "${urlModel.title}"?',
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

  Future<Widget> _loadSvgBytes(Uint8List svgImageBytes) async {
    try {
      return SvgPicture.memory(
        svgImageBytes,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  String _websiteName(String websiteName, int allowedLength) {
    // Logger.printLog('WebsiteName: $websiteName');
    if (websiteName.length < allowedLength) {
      return websiteName;
    }

    final spaced = websiteName.trim().split(' ');
    final initials = StringBuffer();

    for (final ele in spaced) {
      if (ele.isNotEmpty) {
        initials.write(ele[0]);
      }
    }

    return initials.toString();
  }

  @override
  bool get wantKeepAlive => true;
}
