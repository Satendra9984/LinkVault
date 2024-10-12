import 'package:flutter/material.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/widgets/collection_icon_button.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/add_collection_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/collection_list_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/update_collection_template_screen.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard/dashboard_store_screen.dart';

class DashboardCollectionsListScreen extends StatefulWidget {
  const DashboardCollectionsListScreen({
    required this.collectionFetchModel,
    required this.isRootCollection,
    required this.showAddCollectionButton,
    required this.appBarLeadingIcon,
    super.key,
  });

  final CollectionFetchModel collectionFetchModel;
  final bool isRootCollection;
  final bool showAddCollectionButton;
  final Widget appBarLeadingIcon;

  @override
  State<DashboardCollectionsListScreen> createState() =>
      _DashboardCollectionsListScreenState();
}

class _DashboardCollectionsListScreenState
    extends State<DashboardCollectionsListScreen>
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
      showAddCollectionButton: widget.showAddCollectionButton,
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
            builder: (ctx) => CollectionStorePage(
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
        // mainAxisAlignment: MainAxisAlignment.start,
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

  @override
  bool get wantKeepAlive => true;
}
