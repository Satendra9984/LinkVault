// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/add_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/update_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/url_preview_list_template_screen.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:link_vault/src/rss_feeds/presentation/widgets/rss_feed_preview_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlsPreviewListScreen extends StatefulWidget {
  const UrlsPreviewListScreen({
    required this.showBottomBar,
    required this.isRootCollection,
    required this.collectionFetchModel,
    required this.appBarLeadingIcon,
    super.key,
  });

  final ValueNotifier<bool> showBottomBar;
  final bool isRootCollection;
  final CollectionFetchModel collectionFetchModel;
  final Widget appBarLeadingIcon;

  @override
  State<UrlsPreviewListScreen> createState() => _UrlsPreviewListScreenState();
}

class _UrlsPreviewListScreenState extends State<UrlsPreviewListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return UrlPreviewListTemplateScreen(
      collectionFetchModel: widget.collectionFetchModel,
      showAddUrlButton: false,
      onAddUrlPressed: ({String? url}) {},
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
      child: SvgPicture.asset(
        MediaRes.webSurf3SVG,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
