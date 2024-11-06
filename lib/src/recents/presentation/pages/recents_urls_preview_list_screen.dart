// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/url_preview_list_template_screen.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_view_type.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';

class RecentsUrlsPreviewListScreen extends StatefulWidget {
  const RecentsUrlsPreviewListScreen({
    required this.showBottomBar,
    required this.isRootCollection,
    required this.collectionModel,
    required this.appBarLeadingIcon,
    super.key,
  });

  final ValueNotifier<bool> showBottomBar;
  final bool isRootCollection;
  final CollectionModel collectionModel;
  final Widget appBarLeadingIcon;

  @override
  State<RecentsUrlsPreviewListScreen> createState() => _RecentsUrlsPreviewListScreenState();
}

class _RecentsUrlsPreviewListScreenState extends State<RecentsUrlsPreviewListScreen>
    with AutomaticKeepAliveClientMixin {
      final _listViewType = ValueNotifier(UrlViewType.favicons);
  final PageController _pageController = PageController();

  @override
  void initState() {
    // TODO : INITIALIZE LISTVIEWTYPE FROM COLLECTION SETTINGS
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return UrlPreviewListTemplateScreen(
      isRootCollection: widget.isRootCollection,
      collectionModel: widget.collectionModel,
      showAddUrlButton: false,
      onAddUrlPressed: ({String? url}) {},
      onLongPress: (
        urlModel, {
        required List<Widget> urlOptions,
      }) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => UpdateUrlTemplateScreen(
              urlModel: urlModel,
              isRootCollection: widget.isRootCollection,
            ),
          ),
        );
      },
      urlsEmptyWidget: _urlsEmptyWidget(),
      showBottomNavBar: widget.showBottomBar,
      appBar: _appBarBuilder,
    );
  }

  Widget _appBarBuilder({
    required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>> list,
    required List<Widget> actions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: widget.appBarLeadingIcon,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isRootCollection
                ? 'Favourites'
                : widget.collectionModel.name,
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
      child: SvgPicture.asset(
        MediaRes.webSurf3SVG,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
