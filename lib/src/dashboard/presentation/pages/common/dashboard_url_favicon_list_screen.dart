import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart'
    as customChromeTabs;
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/res/app_tutorials.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/url_favicon_widget.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/add_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/update_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/url_favicon_list_template_screen.dart';
import 'package:link_vault/src/app_home/services/custom_tabs_service.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardUrlFaviconListScreen extends StatefulWidget {
  const DashboardUrlFaviconListScreen({
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
  State<DashboardUrlFaviconListScreen> createState() =>
      _DashboardUrlFaviconListScreenState();
}

class _DashboardUrlFaviconListScreenState
    extends State<DashboardUrlFaviconListScreen>
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
      // [TODO] : THIS IS DYNAMIC FIELD
      onTap: () async {
        final theme = Theme.of(context);
        // final stopWatch = Stopwatch()..start();
        // Logger.printLog(
        //   '[url] : ${url.url} ${stopWatch.elapsedMilliseconds}',
        // );
        final uri = Uri.parse(url.url);
        try {
          await Future.wait(
            [
              // CUSTOM CHROME PREFETCHES AND STORES THE WEBPAGE
              // FOR FASTER WEBPAGE LOADING
              CustomTabsService.launchUrl(
                url: url.url,
                theme: theme,
              ),
              // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
              // JUST LIKE APPS IN BACKGROUND TYPE
            ],
          );
        } catch (e) {
          // If the URL launch fails, an exception will be thrown. (For example, if no browser app is installed on the Android device.)
          // debugPrint(e.toString());

          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.inAppBrowserView,
            );
          }
          // stopWatch.stop();
          // Logger.printLog('[url] : stopped ${stopWatch.elapsedMilliseconds}');
        }
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

/*
Using inAppBrowserView with 
if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
            );
          }
I/flutter (13713): [log] : [url] : https://coindcx.com/ 0
I/flutter (13713): [log] : [url] : stopped 125
I/flutter (13713): [log] : [url] : https://news.google.com/ 0
I/flutter (13713): [log] : [url] : stopped 210
I/flutter (13713): [log] : [url] : https://in.bookmyshow.com/explore/home/lucknow 0
I/flutter (13713): [log] : [url] : stopped 43
I/flutter (13713): [log] : [url] : https://www.myntra.com/ 0
I/flutter (13713): [log] : [url] : stopped 37
I/flutter (13713): [log] : [url] : https://nammayatri.in/ 0
I/flutter (13713): [log] : [url] : stopped 45
I/flutter (13713): [log] : [url] : http://www.ajio.com/shop/ajio 0
I/flutter (13713): [log] : [url] : stopped 147
I/flutter (13713): [log] : [url] : https://www.binance.com/en 0
I/flutter (13713): [log] : [url] : stopped 63
I/flutter (13713): [log] : [url] : https://groww.in/ 0
I/flutter (13713): [log] : [url] : stopped 52
I/flutter (13713): [log] : [url] : https://www.google.com/intl/en_in/drive/ 0
I/flutter (13713): [log] : [url] : stopped 65
I/flutter (13713): [log] : [url] : https://www.uber.com/in/en/ 0
I/flutter (13713): [log] : [url] : stopped 61
I/flutter (13713): [log] : [url] : https://www.olacabs.com/ 0
I/flutter (13713): [log] : [url] : stopped 57
I/flutter (22082): [log] : [url] : https://www.flipkart.com/ 0
I/flutter (22082): [log] : [url] : stopped 82
I/flutter (22082): [log] : [url] : https://www.amazon.in/ 0
I/flutter (22082): [log] : [url] : stopped 57
I/flutter (22082): [log] : [url] : https://www.swiggy.com/ 0
I/flutter (22082): [log] : [url] : stopped 62
I/flutter (22082): [log] : [url] : https://www.zomato.com 0
I/flutter (22082): [log] : [url] : stopped 31
I/flutter (22082): [log] : [url] : https://www.digilocker.gov.in/ 0
I/flutter (22082): [log] : [url] : stopped 50
I/flutter (22082): [log] : [url] : https://www.jio.com/selfcare/login/ 1
I/flutter (22082): [log] : [url] : stopped 50
I/flutter (22082): [log] : [url] : https://www.irctc.co.in/ 0
I/flutter (22082): [log] : [url] : stopped 51
I/flutter (22082): [log] : [url] : https://trackmytrain.co.in/ 0
I/flutter (22082): [log] : [url] : stopped 69



Using Default Browser with 
if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.inAppBrowserView,
            );
          }

I/flutter (  416): [log] : [url] : https://coindcx.com/ 1
I/flutter (  416): [log] : [url] : stopped 160
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 113
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 63
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 50
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 47
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 73
I/flutter (  416): [log] : [url] : https://news.google.com/ 0
I/flutter (  416): [log] : [url] : stopped 52
I/flutter (  416): [log] : [url] : https://in.bookmyshow.com/explore/home/lucknow 0
I/flutter (  416): [log] : [url] : stopped 63
I/flutter (  416): [log] : [url] : https://www.myntra.com/ 0
I/flutter (  416): [log] : [url] : stopped 69
I/flutter (  416): [log] : [url] : https://nammayatri.in/ 0
I/flutter (  416): [log] : [url] : stopped 56
I/flutter (  416): [log] : [url] : http://www.ajio.com/shop/ajio 0
I/flutter (  416): [log] : [url] : stopped 62
I/flutter (  416): [log] : [url] : https://www.binance.com/en 0
I/flutter (  416): [log] : [url] : stopped 45
I/flutter (  416): [log] : [url] : https://groww.in/ 0
I/flutter (  416): [log] : [url] : stopped 57
I/flutter (  416): [log] : [url] : https://www.google.com/intl/en_in/drive/ 0
I/flutter (  416): [log] : [url] : stopped 49
I/flutter (  416): [log] : [url] : https://www.uber.com/in/en/ 0
I/flutter (  416): [log] : [url] : stopped 72
I/flutter (  416): [log] : [url] : https://www.olacabs.com/ 0
I/flutter (  416): [log] : [url] : stopped 54
I/flutter (13713): [log] : [url] : https://www.flipkart.com/ 0
I/flutter (13713): [log] : [url] : stopped 85
I/flutter (13713): [log] : [url] : https://www.amazon.in/ 0
I/flutter (13713): [log] : [url] : stopped 63
I/flutter (13713): [log] : [url] : https://www.swiggy.com/ 0
I/flutter (13713): [log] : [url] : stopped 79
I/flutter (13713): [log] : [url] : https://www.zomato.com 0
I/flutter (13713): [log] : [url] : stopped 45
I/flutter (13713): [log] : [url] : https://www.digilocker.gov.in/ 0
I/flutter (13713): [log] : [url] : stopped 53
I/flutter (13713): [log] : [url] : https://www.jio.com/selfcare/login/ 0
I/flutter (13713): [log] : [url] : stopped 58
I/flutter (13713): [log] : [url] : https://www.irctc.co.in/ 0
I/flutter (13713): [log] : [url] : stopped 47
I/flutter (13713): [log] : [url] : https://trackmytrain.co.in/ 0
I/flutter (13713): [log] : [url] : stopped 66



After Using CustomTabs
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 168
I/flutter (  416): [log] : [url] : https://coindcx.com/ 0
I/flutter (  416): [log] : [url] : stopped 49
I/flutter (  416): [log] : [url] : https://news.google.com/ 0
I/flutter (  416): [log] : [url] : stopped 31
I/flutter (  416): [log] : [url] : https://in.bookmyshow.com/explore/home/lucknow 0
I/flutter (  416): [log] : [url] : stopped 32
I/flutter (  416): [log] : [url] : https://www.myntra.com/ 0
I/flutter (  416): [log] : [url] : stopped 52
I/flutter (  416): [log] : [url] : https://nammayatri.in/ 0
I/flutter (  416): [log] : [url] : stopped 34
I/flutter (  416): [log] : [url] : http://www.ajio.com/shop/ajio 0
I/flutter (  416): [log] : [url] : stopped 26
I/flutter (  416): [log] : [url] : https://www.binance.com/en 0
I/flutter (  416): [log] : [url] : stopped 49
I/flutter (  416): [log] : [url] : https://groww.in/ 0
I/flutter (  416): [log] : [url] : stopped 39
I/flutter (  416): [log] : [url] : https://www.google.com/intl/en_in/drive/ 0
I/flutter (  416): [log] : [url] : stopped 41
I/flutter (  416): [log] : [url] : https://www.uber.com/in/en/ 0
I/flutter (  416): [log] : [url] : stopped 28
I/flutter (  416): [log] : [url] : https://www.olacabs.com/ 0
I/flutter (  416): [log] : [url] : stopped 63
I/flutter (  416): [log] : [url] : https://www.flipkart.com/ 0
I/flutter (  416): [log] : [url] : stopped 34
I/flutter (  416): [log] : [url] : https://www.amazon.in/ 0
I/flutter (  416): [log] : [url] : stopped 31
I/flutter (  416): [log] : [url] : https://www.swiggy.com/ 0
I/flutter (  416): [log] : [url] : stopped 36
I/flutter (  416): [log] : [url] : https://www.zomato.com 0
I/flutter (  416): [log] : [url] : stopped 28
I/flutter (  416): [log] : [url] : https://www.digilocker.gov.in/ 0
I/flutter (  416): [log] : [url] : stopped 25
I/flutter (  416): [log] : [url] : https://www.jio.com/selfcare/login/ 0
I/flutter (  416): [log] : [url] : stopped 30
I/flutter (  416): [log] : [url] : https://www.irctc.co.in/ 0
I/flutter (  416): [log] : [url] : stopped 27
I/flutter (  416): [log] : [url] : https://trackmytrain.co.in/ 0
I/flutter (  416): [log] : [url] : stopped 108


*/