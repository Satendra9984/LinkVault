// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/update_url_template_screen.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/url_preview_list_template_screen.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/rss_feeds/data/constants/rss_feed_constants.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:lottie/lottie.dart';

class SavedFeedsPreviewListScreen extends StatefulWidget {
  const SavedFeedsPreviewListScreen({
    required this.showBottomBar,
    required this.isRootCollection,
    required this.collectionId,
    required this.appBarLeadingIcon,
    super.key,
  });

  final ValueNotifier<bool> showBottomBar;
  final bool isRootCollection;
  final String collectionId;
  final Widget appBarLeadingIcon;

  @override
  State<SavedFeedsPreviewListScreen> createState() =>
      _SavedFeedsPreviewListScreenState();
}

class _SavedFeedsPreviewListScreenState
    extends State<SavedFeedsPreviewListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    context.read<CollectionsCubit>().fetchCollection(
          collectionId: widget.collectionId,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: widget.isRootCollection,
          collectionName: 'My Feeds',
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<CollectionsCubit, CollectionsState>(
      listener: (ctx, state) {},
      builder: (context, state) {
        // final size = MediaQuery.of(context).size;
        final collectionCubit = context.read<CollectionsCubit>();
        final globalUserCubit = context.read<GlobalUserCubit>();

        final fetchCollection = state.collections[widget.collectionId];

        if (fetchCollection == null) {
          collectionCubit.fetchCollection(
            collectionId: widget.collectionId,
            userId: globalUserCubit.state.globalUser!.id,
            isRootCollection: widget.isRootCollection,
            collectionName: 'My Feeds',
          );
        }

        if (fetchCollection == null ||
            fetchCollection.collectionFetchingState == LoadingStates.loading) {
          return _showLoadingWidget();
        }

        if (fetchCollection.collectionFetchingState ==
                LoadingStates.errorLoading ||
            fetchCollection.collection == null) {
          return _showErrorLoadingWidget(
            () => collectionCubit.fetchCollection(
              collectionId: widget.collectionId,
              userId: globalUserCubit.state.globalUser!.id,
              isRootCollection: widget.isRootCollection,
              collectionName: 'My Feeds',
            ),
          );
        }

        return UrlPreviewListTemplateScreen(
          collectionModel: fetchCollection.collection!,
          showAddUrlButton: false,
          onAddUrlPressed: ({String? url}) {},
          onLongPress: (urlModel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => UpdateUrlTemplateScreen(
                  urlModel: urlModel,
                  isRootCollection: widget.isRootCollection,
                  onDeleteURLCallback: (urlModel) async {
                    final cubit = context.read<RssFeedCubit>();

                    var collectionId =
                        'hzx1SlJoeyRcnEvTx0U1OdkXMEQ2Rss_Feedsaved_feeds';

                    // Check if the string contains 'saved_feeds'
                    if (collectionId.contains('saved_feeds')) {
                      // Remove 'saved_feeds' from the string
                      collectionId = collectionId.replaceAll('saved_feeds', '');
                    }

                    final forRssFeedUpdate = urlModel.copyWith(
                      isOffline: false,
                      collectionId: collectionId,
                    );

                    await cubit.updateRSSFeed(feedUrlModel: forRssFeedUpdate);
                  },
                ),
              ),
            );
          },
          urlsEmptyWidget: _urlsEmptyWidget(),
          showBottomNavBar: widget.showBottomBar,
          appBar: ({
            required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>>
                list,
            required List<Widget> actions,
          }) {
            return AppBar(
              surfaceTintColor: ColourPallette.mystic,
              title: Row(
                children: [
                  widget.appBarLeadingIcon,
                  const SizedBox(width: 8),
                  Text(
                    widget.isRootCollection
                        ? 'My Feeds'
                        : fetchCollection.collection!.name,
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
          },
        );
      },
    );
  }

  Widget _urlsEmptyWidget() {
    return Center(
      child: SvgPicture.asset(
        MediaRes.webSurf3SVG,
      ),
    );
  }

  Widget _showErrorLoadingWidget(
    void Function() onPress,
  ) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              MediaRes.errorANIMATION,
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'Oops !!!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Something went wrong while fetching the collection from server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              text: 'Try Again',
              onPressed: () => onPress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showLoadingWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            LottieBuilder.asset(
              MediaRes.loadingANIMATION,
            ),
            const Text(
              'Loading Collection...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
