import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/url_favicon_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/url_preview_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/filter_popup_menu_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/network_image_builder_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_favicon_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_launch_type.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_view_type.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/res/app_tutorials.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/presentation/pages/webview.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/add_rss_feed_url_screen.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/update_rss_url_page.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class RssFeedUrlsListWidget extends StatefulWidget {
  const RssFeedUrlsListWidget({
    required this.collectionModel,
    required this.isRootCollection,
    required this.showBottomNavBar,
    super.key,
  });

  // final String title;
  final bool isRootCollection;
  final ValueNotifier<bool> showBottomNavBar;

  final CollectionModel collectionModel;

  @override
  State<RssFeedUrlsListWidget> createState() => _RssFeedUrlsListWidgetState();
}

class _RssFeedUrlsListWidgetState extends State<RssFeedUrlsListWidget>
    with AutomaticKeepAliveClientMixin {
  final _listViewType = ValueNotifier(UrlViewType.favicons);
  final PageController _pageController = PageController();

  @override
  void initState() {
    // TODO : INITIALIZE LISTVIEWTYPE FROM COLLECTION SETTINGS
    super.initState();
  }

  void _onAddUrlPressed({String? url}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddRssFeedUrlPage(
          parentCollection: widget.collectionModel,
          url: url,
          isRootCollection: widget.isRootCollection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageView(
      controller: _pageController,
      onPageChanged: (page) {},
      physics: const NeverScrollableScrollPhysics(),
      children: [
        UrlFaviconListTemplateScreen(
          isRootCollection: widget.isRootCollection,
          collectionModel: widget.collectionModel,
          showAddUrlButton: true,
          showBottomNavBar: widget.showBottomNavBar,
          onAddUrlPressed: _onAddUrlPressed,
          appBar: _faviconsListAppBarBuilder,
          urlsEmptyWidget: _urlsEmptyWidget(context),
          onUrlModelItemFetchedWidget: _urlFaviconItemBuilder,
        ),
        UrlPreviewListTemplateScreen(
          collectionModel: widget.collectionModel,
          isRootCollection: widget.isRootCollection,
          showAddUrlButton: false,
          onAddUrlPressed: ({String? url}) {},
          onLongPress: (
            urlModel, {
            required List<Widget> urlOptions,
          }) async {
            await showUrlOptionsBottomSheet(
              context,
              urlModel: urlModel,
              urlOptions: urlOptions,
            );
          },
          urlsEmptyWidget: _urlsEmptyWidget(context),
          showBottomNavBar: widget.showBottomNavBar,
          appBar: _faviconsListAppBarBuilder,
        ),
      ],
    );
  }

  Widget _urlFaviconItemBuilder({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required int index,
    required List<Widget> urlOptions,
  }) {
    final urlModel = list.value[index].value.urlModel!;

    return UrlFaviconLogoWidget(
      urlPreloadMethod: widget.isRootCollection
          ? UrlPreloadMethods.httpGet
          : UrlPreloadMethods.httpGet,
      onTap: () async {
        final urlLaunchTypeLocalNotifier =
            ValueNotifier(UrlLaunchType.customTabs);

        if (urlModel.settings != null &&
            urlModel.settings!.containsKey(urlLaunchType)) {
          urlLaunchTypeLocalNotifier.value = UrlLaunchType.fromString(
            urlModel.settings![urlLaunchType].toString(),
          );
        }
        switch (urlLaunchTypeLocalNotifier.value) {
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
                    url: urlModel.url,
                  ),
                ),
              );

              break;
            }
          case UrlLaunchType.readingMode:
            {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => DashboardWebView(
                    url: urlModel.url,
                  ),
                ),
              );

              break;
            }
          case UrlLaunchType.separateBrowserWindow:
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
        }
      },
      onLongPress: (urlMetaData) async {
        final urlc = urlModel.copyWith(metaData: urlMetaData);
        await showUrlOptionsBottomSheet(
          context,
          urlModel: urlc,
          urlOptions: urlOptions,
        );
      },
      urlModelData: urlModel,
    );
  }

  Widget _faviconsListAppBarBuilder({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required List<Widget> actions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: Row(
        children: [
          const Icon(
            Icons.dashboard_rounded,
            color: ColourPallette.mountainMeadow,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.collectionModel.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      actions: [
        _urlViewTypeOptions(),
        ...actions,
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> showUrlOptionsBottomSheet(
    BuildContext context, {
    required UrlModel urlModel,
    required List<Widget> urlOptions,
  }) async {
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

    final showLastUpdated = ValueNotifier(false);
    urlOptions
      ..insert(
        0,
        // UPDATE URL
        BottomSheetOption(
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

              final updatedAt = urlModel.updatedAt;
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
                builder: (ctx) => UpdateRssFeedUrlPage(
                  urlModel: urlModel,
                  isRootCollection: widget.isRootCollection,
                  onDeleteURLCallback: (urlModel) async {},
                ),
              ),
            ).then(
              (_) {
                Navigator.pop(context);
              },
            );
          },
        ),
      )
      ..insert(
        2,
        // ADD TO FAVOURITES
        BottomSheetOption(
          leadingIcon: Icons.bookmark_add_rounded,
          title: const Text('Favourites', style: titleTextStyle),
          trailing: Builder(
            builder: (ctx) {
              if (urlModel.isFavourite == false) {
                return const SizedBox.shrink();
              }

              return Icon(
                Icons.check_circle_rounded,
                color: ColourPallette.salemgreen.withOpacity(0.5),
              );
            },
          ),
          onTap: () async {
            // if (urlModel.isFavourite) return;

            final urlCrudCubit = context.read<UrlCrudCubit>();
            final globalUser =
                context.read<GlobalUserCubit>().getGlobalUser()!.id;

            await Future.wait(
              [
                urlCrudCubit.addUrl(
                  isRootCollection: true,
                  urlData: urlModel.copyWith(
                    parentUrlModelFirestoreId: urlModel.firestoreId,
                    collectionId: '$globalUser$favourites',
                    isFavourite: true,
                  ),
                ),
                urlCrudCubit.updateUrl(
                  urlData: urlModel.copyWith(
                    isFavourite: true,
                  ),
                ),
                Future(() => Navigator.pop(context)),
              ],
            );
          },
        ),
      );
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
                    Text(
                      StringUtils.capitalizeEachWord(urlModel.title),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ...urlOptions,

              // DELETE URL
              BottomSheetOption(
                leadingIcon: Icons.delete_rounded,
                title: const Text('Delete', style: titleTextStyle),
                onTap: () async {
                  await showDeleteConfirmationDialog(
                    context,
                    urlModel,
                    () => context.read<UrlCrudCubit>().deleteUrl(
                          urlData: urlModel,
                          isRootCollection: widget.isRootCollection,
                        ),
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

  Widget _urlViewTypeOptions() {
    return FilterPopupMenuButton(
      icon: const Icon(
        Icons.format_align_center_rounded,
      ),
      menuItems: [
        PopupMenuItem<UrlViewType>(
          value: UrlViewType.favicons,
          onTap: () {
            _listViewType.value = UrlViewType.favicons;
            _pageController.jumpToPage(0);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                UrlViewType.favicons.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColourPallette.black,
                ),
              ),
              ValueListenableBuilder<UrlViewType>(
                valueListenable: _listViewType,
                builder: (context, listViewType, child) {
                  if (listViewType == UrlViewType.favicons) {
                    return const Icon(
                      Icons.check_box_rounded,
                      color: ColourPallette.salemgreen,
                    );
                  }

                  return const Icon(
                    Icons.check_box_outline_blank_outlined,
                  );
                },
              ),
            ],
          ),
        ),
        PopupMenuItem<UrlViewType>(
          value: UrlViewType.previews,
          onTap: () {
            _listViewType.value = UrlViewType.previews;
            _pageController.jumpToPage(1);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                UrlViewType.previews.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColourPallette.black,
                ),
              ),
              ValueListenableBuilder<UrlViewType>(
                valueListenable: _listViewType,
                builder: (context, listViewType, child) {
                  if (listViewType == UrlViewType.previews) {
                    return const Icon(
                      Icons.check_box_rounded,
                      color: ColourPallette.salemgreen,
                    );
                  }

                  return const Icon(
                    Icons.check_box_outline_blank_outlined,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _urlsEmptyWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _linkTextWidget(
                  onTap: () async {
                    const howToAddlink = AppLinks.whatIsRSSFeed;
                    final uri = Uri.parse(howToAddlink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: ColourPallette.white,
                    size: 12,
                  ),
                  text: const Text(
                    'What is a RSS Feed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _linkTextWidget(
                  onTap: () async {
                    const howToAddlink = AppLinks.howToAddRSSFeedLinkOfWebsite;
                    final uri = Uri.parse(howToAddlink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: ColourPallette.white,
                    size: 12,
                  ),
                  text: const Text(
                    'How To Use It',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Best Practices and Directions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 16),
                _linkTextWidget(
                  onTap: () async {},
                  leading: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  iconColor: ColourPallette.white,
                  text: const Text(
                    'Use Collections for different topics.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _linkTextWidget(
                  onTap: () async {},
                  leading: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  iconColor: ColourPallette.white,
                  text: const Expanded(
                    child: Text(
                      'Add only optimal number of URLs (<30*) for more efficient use and readability.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _linkTextWidget(
                  onTap: () async {},
                  leading: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  iconColor: ColourPallette.white,
                  text: const Expanded(
                    child: Text(
                      'Each feed will refresh at 8 Hours interval for productive usage.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 'Give FeedBack And Suggestions:',
                const Text(
                  'Give FeedBack And Suggestions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 16,
                  spacing: 20,
                  children: [
                    _linkTextWidget(
                      onTap: () async {
                        const howToAddlink = AppLinks.linkVaultDiscord;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(
                        Icons.discord,
                        color: ColourPallette.white,
                        size: 12,
                      ),
                      iconColor: Colors.deepPurple,
                      text: const Text(
                        'Discord',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _linkTextWidget(
                      onTap: () async {
                        const howToAddlink = AppLinks.linkVaultRedditCommunity;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(
                        Icons.reddit_rounded,
                        color: ColourPallette.white,
                        size: 12,
                      ),
                      iconColor: Colors.orange.shade800,
                      text: const Text(
                        'Reddit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _linkTextWidget(
                      onTap: () async {
                        const howToAddlink = AppLinks.twitterSatendraPal;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(
                        Icons.close,
                        color: ColourPallette.white,
                        size: 12,
                      ),
                      iconColor: ColourPallette.black,
                      text: const Text(
                        'Twitter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkTextWidget({
    required VoidCallback onTap,
    required Widget leading,
    required Widget text,
    Color? iconColor,
  }) {
    iconColor ??= ColourPallette.error;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: iconColor,
            ),
            child: leading,
          ),
          const SizedBox(width: 8),
          text,
        ],
      ),
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
    // // Logger.printLog('WebsiteName: $websiteName');
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
