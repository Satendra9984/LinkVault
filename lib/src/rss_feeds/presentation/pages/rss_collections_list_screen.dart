import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/presentation_layer/pages/add_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/collection_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/collection_icon_button.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_feed_store_screen.dart';

class RssCollectionsListScreen extends StatefulWidget {
  const RssCollectionsListScreen({
    required this.collectionModel,
    required this.isRootCollection,
    required this.appBarLeadingIcon,
    super.key,
  });

  final CollectionModel collectionModel;
  final bool isRootCollection;
  final Widget appBarLeadingIcon;

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
          parentCollection: widget.collectionModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CollectionsListScreenTemplate(
      onAddCollectionPressed: _onAddCollectionPressed,
      collectionModel: widget.collectionModel,
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
              appBarLeadingIcon: widget.appBarLeadingIcon,
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
            widget.isRootCollection ? 'My Feeds' : widget.collectionModel.name,
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
