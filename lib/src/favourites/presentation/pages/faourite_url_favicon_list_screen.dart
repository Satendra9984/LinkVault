import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/pages/add_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/url_favicon_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_favicon_widget.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/res/app_tutorials.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FavouritesUrlFaviconListScreen extends StatefulWidget {
  const FavouritesUrlFaviconListScreen({
    required this.collectionModel,
    required this.isRootCollection,
    required this.showAddUrlButton,
    required this.appBarLeadingIcon,
    super.key,
  });

  final CollectionModel collectionModel;
  final bool isRootCollection;
  final bool showAddUrlButton;
  final Widget appBarLeadingIcon;

  @override
  State<FavouritesUrlFaviconListScreen> createState() =>
      _FavouritesUrlFaviconListScreenState();
}

class _FavouritesUrlFaviconListScreenState
    extends State<FavouritesUrlFaviconListScreen>
    with AutomaticKeepAliveClientMixin {
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
    return UrlFaviconListTemplateScreen(
      collectionModel: widget.collectionModel,
      showAddUrlButton: widget.showAddUrlButton,
      onAddUrlPressed: _onAddUrlPressed,
      appBar: _appBarBuilder,
      urlsEmptyWidget: _urlsEmptyWidget(),
      onUrlModelItemFetchedWidget: _urlItemBuilder,
    );
  }

  Widget _urlItemBuilder({
    required ValueNotifier<List<UrlFetchStateModel>> list,
    required int index,
  }) {
    final url = list.value[index].urlModel!;

    return UrlFaviconLogoWidget(
      urlPreloadMethod: widget.isRootCollection
          ? UrlPreloadMethods.httpGet
          : UrlPreloadMethods.httpHead,
      onTap: () async {
        final theme = Theme.of(context);

        // CUSTOM CHROME PREFETCHES AND STORES THE WEBPAGE
        // FOR FASTER WEBPAGE LOADING
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
      // [TODO] : THIS IS DYNAMIC FIELD
      onLongPress: (urlMetaData) {
        final urlc = url.copyWith(metaData: urlMetaData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => UpdateUrlTemplateScreen(
              urlModel: urlc,
              isRootCollection: widget.isRootCollection,
            ),
          ),
        );
      },
      urlModelData: url,
    );
  }

  Widget _appBarBuilder({
    required ValueNotifier<List<UrlFetchStateModel>> list,
    required List<Widget> actions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: Row(
        children: [
          widget.appBarLeadingIcon,
          const SizedBox(width: 8),
          Text(
            widget.isRootCollection ? 'LinkVault' : widget.collectionModel.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        ...actions,
      ],
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