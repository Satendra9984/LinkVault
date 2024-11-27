import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/pages/add_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/collection_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/collection_icon_button.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_store_screen.dart';

class DashboardCollectionsListScreen extends StatefulWidget {
  const DashboardCollectionsListScreen({
    required this.collectionModel,
    required this.isRootCollection,
    required this.showAddCollectionButton,
    required this.appBarLeadingIcon,
    super.key,
  });

  final CollectionModel collectionModel;
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
          parentCollection: widget.collectionModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CollectionsListScreenTemplate(
      isRootCollection: widget.isRootCollection,
      onAddCollectionPressed: _onAddCollectionPressed,
      collectionModel: widget.collectionModel,
      showAddCollectionButton: widget.showAddCollectionButton,
      onCollectionItemFetchedWidget: _collectionItemBuilder,
      appBar: _getAppBar,
    );
  }

  Widget _collectionItemBuilder({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required int index,
    required List<Widget> Function(CollectionModel) collectionOptions,
  }) {
    final subCollection = list.value[index];
    return FolderIconButton(
      collection: subCollection.collection!,
      onLongPress: () async {
        await showCollectionModelOptionsBottomSheet(
          context,
          collectionModel: subCollection.collection,
          collectionOptions: subCollection.collection == null
              ? <Widget>[]
              : collectionOptions(subCollection.collection!),
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
    required List<Widget> Function(CollectionModel) collectionOptions,
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
        ...actions,
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => showCollectionModelOptionsBottomSheet(
            context,
            collectionOptions: collectionOptions(widget.collectionModel),
            collectionModel: widget.collectionModel,
          ),
          child: const Icon(
            Icons.keyboard_option_key_rounded,
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  // FOR THE COLLECTION-MODEL
  Future<void> showCollectionModelOptionsBottomSheet(
    BuildContext context, {
    required List<Widget> collectionOptions,
    required CollectionModel? collectionModel,
  }) async {
    const titleTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    final size = MediaQuery.of(context).size;

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
                    SvgPicture.asset(
                      MediaRes.folderSVG,
                      height: 16,
                      width: 16,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.dashboard_rounded,
                      color: ColourPallette.mountainMeadow,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      StringUtils.capitalizeEachWord(
                        collectionModel?.name ?? '--',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...collectionOptions,
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

  @override
  bool get wantKeepAlive => true;
}
