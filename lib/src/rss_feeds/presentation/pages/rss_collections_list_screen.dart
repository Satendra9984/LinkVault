import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/collection_icon_button.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/add_collection_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/collection_list_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/update_collection_template_screen.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_feed_store_page.dart';

class RssCollectionsListScreen extends StatefulWidget {
  const RssCollectionsListScreen({
    required this.collectionFetchModel,
    required this.isRootCollection,
    super.key,
  });

  final CollectionFetchModel collectionFetchModel;
  final bool isRootCollection;

  @override
  State<RssCollectionsListScreen> createState() =>
      _RssCollectionsListScreenState();
}

class _RssCollectionsListScreenState extends State<RssCollectionsListScreen>
    with AutomaticKeepAliveClientMixin {
  void _onAddCollectionPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddCollectionTemplateScreen(
          parentCollection: widget.collectionFetchModel.collection!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CollectionsListScreenTemplate(
      onAddCollectionPressed: _onAddCollectionPressed,
      collectionFetchModel: widget.collectionFetchModel,
      showAddCollectionButton: true,
      onCollectionItemFetchedWidget: _collectionItemBuilder,
      appBar: _getAppBar,
    );
  }

  Widget _collectionItemBuilder({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required int index,
  }) {
    final subCollection = list.value[index];
    return FolderIconButton(
      collection: subCollection.collection!,
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => UpdateCollectionTemplateScreen(
              collection: subCollection.collection!,
            ),
          ),
        );
      },
      onPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => RssFeedCollectionStorePage(
              collectionId: subCollection.collection!.id,
              isRootCollection: false,
            ),
          ),
        );
      },
    );
  }

  Widget _getAppBar({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required List<Widget> actions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
      actions: [
        ...actions,
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
