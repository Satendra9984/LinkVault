import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:link_vault/core/common/presentation_layer/pages/add_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/url_favicon_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/url_preview_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/filter_popup_menu_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/network_image_builder_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_favicon_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/snakbar_type.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_view_type.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/res/app_tutorials.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/services/clipboard_service.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/presentation/pages/webview.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardUrlFaviconListScreen extends StatefulWidget {
  const DashboardUrlFaviconListScreen({
    required this.collectionModel,
    required this.isRootCollection,
    required this.showAddUrlButton,
    required this.appBarLeadingIcon,
    required this.showBottomNavBar,
    super.key,
  });

  final CollectionModel collectionModel;
  final bool isRootCollection;
  final bool showAddUrlButton;
  final ValueNotifier<bool> showBottomNavBar;

  final Widget appBarLeadingIcon;

  @override
  State<DashboardUrlFaviconListScreen> createState() =>
      _DashboardUrlFaviconListScreenState();
}

class _DashboardUrlFaviconListScreenState
    extends State<DashboardUrlFaviconListScreen>
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
        builder: (ctx) => AddUrlTemplateScreen(
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
          showAddUrlButton: widget.showAddUrlButton,
          showBottomNavBar: widget.showBottomNavBar,
          onAddUrlPressed: _onAddUrlPressed,
          appBar: _faviconsListAppBarBuilder,
          urlsEmptyWidget: _urlsEmptyWidget(),
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
          urlsEmptyWidget: _urlsEmptyWidget(),
          showBottomNavBar: widget.showBottomNavBar,
          appBar: _faviconsListAppBarBuilder,
        ),
      ],
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
            Logger.printLog('currentpage: ${_pageController.page}');
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
            Logger.printLog('currentpage: ${_pageController.page}');
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

  Widget _urlFaviconItemBuilder({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required int index,
    required List<Widget> urlOptions,
  }) {
    final url = list.value[index].value.urlModel!;

    return UrlFaviconLogoWidget(
      urlPreloadMethod: widget.isRootCollection
          ? UrlPreloadMethods.httpGet
          : UrlPreloadMethods.httpGet,
      onTap: () async {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (ctx) => DashboardWebView(
        //       url: url.url,
        //     ),
        //   ),
        // );
        final theme = Theme.of(context);
        await CustomTabsService.launchUrl(
          url: url.url,
          theme: theme,
        ).then(
          (_) async {
            // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
            // JUST LIKE APPS IN BACKGROUND TYPE
          },
        );
      },
      onLongPress: (urlMetaData) async {
        final urlc = url.copyWith(metaData: urlMetaData);
        await showUrlOptionsBottomSheet(
          context,
          urlModel: urlc,
          urlOptions: urlOptions,
        );
      },
      urlModelData: url,
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

    final _showLastUpdated = ValueNotifier(false);
    urlOptions
      ..insert(
        0,
        // UPDATE URL
        BottomSheetOption(
          leadingIcon: Icons.replay_circle_filled_outlined,
          title: const Text('Update', style: titleTextStyle),
          trailing: ValueListenableBuilder(
            valueListenable: _showLastUpdated,
            builder: (ctx, showLastUpdated, _) {
              if (!showLastUpdated) {
                return GestureDetector(
                  onTap: () => _showLastUpdated.value = !_showLastUpdated.value,
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
                onTap: () => _showLastUpdated.value = !_showLastUpdated.value,
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
                builder: (ctx) => UpdateUrlTemplateScreen(
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
          title: const Text('Add To Favourites', style: titleTextStyle),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: NetworkImageBuilderWidget(
                          imageUrl: urlModel.metaData!.faviconUrl!,
                          compressImage: false,
                          errorWidgetBuilder: () {
                            return const SizedBox.shrink();
                          },
                          successWidgetBuilder: (imageData) {
                            final imageBytes = imageData.imageBytesData!;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.contain,
                                height: 24,
                                width: 24,
                                errorBuilder: (ctx, _, __) {
                                  return const SizedBox.shrink();
                                },
                              ),
                            );
                          },
                        ),
                      ),
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

  Widget _urlsEmptyWidget() {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            MediaRes.webSurf1SVG,
          ),
          GestureDetector(
            onTap: () async {
              const howToAddlink = AppLinks.howToAddURLVideoTutorialLink;
              final uri = Uri.parse(howToAddlink);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColourPallette.error,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: ColourPallette.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Watch How to Add URL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// WILL BE USE FOR MEDIUM ARTICLE
/*
Using Default settings with 
if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
            );
          }
URL Opened https://coindcx.com/ 0
Total Time Taken 125
URL Opened https://news.google.com/ 0
Total Time Taken 210
URL Opened https://in.bookmyshow.com/explore/home/lucknow 0
Total Time Taken 43
URL Opened https://www.myntra.com/ 0
Total Time Taken 37
URL Opened https://nammayatri.in/ 0
Total Time Taken 45
URL Opened http://www.ajio.com/shop/ajio 0
Total Time Taken 147
URL Opened https://www.binance.com/en 0
Total Time Taken 63
URL Opened https://groww.in/ 0
Total Time Taken 52
URL Opened https://www.google.com/intl/en_in/drive/ 0
Total Time Taken 65
URL Opened https://www.uber.com/in/en/ 0
Total Time Taken 61
URL Opened https://www.olacabs.com/ 0
Total Time Taken 57
URL Opened https://www.flipkart.com/ 0
Total Time Taken 82
URL Opened https://www.amazon.in/ 0
Total Time Taken 57
URL Opened https://www.swiggy.com/ 0
Total Time Taken 62
URL Opened https://www.zomato.com 0
Total Time Taken 31
URL Opened https://www.digilocker.gov.in/ 0
Total Time Taken 50
URL Opened https://www.jio.com/selfcare/login/ 1
Total Time Taken 50
URL Opened https://www.irctc.co.in/ 0
Total Time Taken 51
URL Opened https://trackmytrain.co.in/ 0
Total Time Taken 69



Using Default Browser with 
if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.inAppBrowserView,
            );
          }

URL Opened https://coindcx.com/ 1
Total Time Taken 160
URL Opened https://coindcx.com/ 0
Total Time Taken 113
URL Opened https://coindcx.com/ 0
Total Time Taken 63
URL Opened https://coindcx.com/ 0
Total Time Taken 50
URL Opened https://coindcx.com/ 0
Total Time Taken 47
URL Opened https://coindcx.com/ 0
Total Time Taken 73
URL Opened https://news.google.com/ 0
Total Time Taken 52
URL Opened https://in.bookmyshow.com/explore/home/lucknow 0
Total Time Taken 63
URL Opened https://www.myntra.com/ 0
Total Time Taken 69
URL Opened https://nammayatri.in/ 0
Total Time Taken 56
URL Opened http://www.ajio.com/shop/ajio 0
Total Time Taken 62
URL Opened https://www.binance.com/en 0
Total Time Taken 45
URL Opened https://groww.in/ 0
Total Time Taken 57
URL Opened https://www.google.com/intl/en_in/drive/ 0
Total Time Taken 49
URL Opened https://www.uber.com/in/en/ 0
Total Time Taken 72
URL Opened https://www.olacabs.com/ 0
Total Time Taken 54
URL Opened https://www.flipkart.com/ 0
Total Time Taken 85
URL Opened https://www.amazon.in/ 0
Total Time Taken 63
URL Opened https://www.swiggy.com/ 0
Total Time Taken 79
URL Opened https://www.zomato.com 0
Total Time Taken 45
URL Opened https://www.digilocker.gov.in/ 0
Total Time Taken 53
URL Opened https://www.jio.com/selfcare/login/ 0
Total Time Taken 58
URL Opened https://www.irctc.co.in/ 0
Total Time Taken 47
URL Opened https://trackmytrain.co.in/ 0
Total Time Taken 66



After Using CustomTabs
URL Opened https://coindcx.com/ 0
Total Time Taken 168
URL Opened https://coindcx.com/ 0
Total Time Taken 49
URL Opened https://news.google.com/ 0
Total Time Taken 31
URL Opened https://in.bookmyshow.com/explore/home/lucknow 0
Total Time Taken 32
URL Opened https://www.myntra.com/ 0
Total Time Taken 52
URL Opened https://nammayatri.in/ 0
Total Time Taken 34
URL Opened http://www.ajio.com/shop/ajio 0
Total Time Taken 26
URL Opened https://www.binance.com/en 0
Total Time Taken 49
URL Opened https://groww.in/ 0
Total Time Taken 39
URL Opened https://www.google.com/intl/en_in/drive/ 0
Total Time Taken 41
URL Opened https://www.uber.com/in/en/ 0
Total Time Taken 28
URL Opened https://www.olacabs.com/ 0
Total Time Taken 63
URL Opened https://www.flipkart.com/ 0
Total Time Taken 34
URL Opened https://www.amazon.in/ 0
Total Time Taken 31
URL Opened https://www.swiggy.com/ 0
Total Time Taken 36
URL Opened https://www.zomato.com 0
Total Time Taken 28
URL Opened https://www.digilocker.gov.in/ 0
Total Time Taken 25
URL Opened https://www.jio.com/selfcare/login/ 0
Total Time Taken 30
URL Opened https://www.irctc.co.in/ 0
Total Time Taken 27
URL Opened https://trackmytrain.co.in/ 0
Total Time Taken 108

*/
