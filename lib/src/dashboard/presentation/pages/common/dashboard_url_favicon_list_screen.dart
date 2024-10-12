import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/res/app_tutorials.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/url_favicon_widget.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/add_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/update_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/url_favicon_list_template_screen.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardUrlFaviconListScreen extends StatefulWidget {
  const DashboardUrlFaviconListScreen({
    required this.collectionFetchModel,
    required this.isRootCollection,
    required this.showAddUrlButton,
    required this.appBarLeadingIcon,
    super.key,
  });

  final CollectionFetchModel collectionFetchModel;
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
          parentCollection: widget.collectionFetchModel.collection!,
          url: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return UrlFaviconListTemplateScreen(
      collectionFetchModel: widget.collectionFetchModel,
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
        final uri = Uri.parse(url.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      // [TODO] : THIS IS DYNAMIC FIELD
      onDoubleTap: (urlMetaData) {
        final urlc = url.copyWith(metaData: urlMetaData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => UpdateUrlTemplateScreen(urlModel: urlc),
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
            '${widget.isRootCollection ? 'LinkVault' : widget.collectionFetchModel.collection?.name}',
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
