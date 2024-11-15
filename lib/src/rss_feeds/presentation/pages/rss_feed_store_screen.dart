import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_bottom_nav_bar.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/rss_feeds/data/constants/rss_feed_constants.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_collections_list_screen.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_feed_preview_list_screen.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_url_favicon_list_screen.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/saved_feeds_list_screen.dart';
import 'package:lottie/lottie.dart';

class RssFeedCollectionStorePage extends StatefulWidget {
  const RssFeedCollectionStorePage({
    required this.collectionId,
    required this.isRootCollection,
    required this.appBarLeadingIcon,
    super.key,
  });
  final String collectionId;
  final bool isRootCollection;
  final Widget appBarLeadingIcon;

  @override
  State<RssFeedCollectionStorePage> createState() =>
      _RssFeedCollectionStorePageState();
}

class _RssFeedCollectionStorePageState extends State<RssFeedCollectionStorePage>
    with AutomaticKeepAliveClientMixin {
  final _showBottomNavBar = ValueNotifier(true);
  final PageController _pageController = PageController();

  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    // Add a listener to detect page changes
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showBottomNavBar.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColourPallette.white,
      bottomNavigationBar: _getBottomNavBar(),
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
        builder: (context, state) {
          // final size = MediaQuery.of(context).size;
          final collectionCubit = context.read<CollectionsCubit>();
          final globalUserCubit = context.read<GlobalUserCubit>();

          final fetchCollection = state.collections[widget.collectionId];

          if (fetchCollection == null) {
            context.read<CollectionsCubit>().fetchCollection(
                  collectionId: widget.collectionId,
                  userId: context.read<GlobalUserCubit>().state.globalUser!.id,
                  isRootCollection: widget.isRootCollection,
                  collectionName: 'My Feeds',
                );
          }

          if (fetchCollection == null ||
              fetchCollection.collectionFetchingState ==
                  LoadingStates.loading) {
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
              ),
            );
          }

          final collection = fetchCollection.collection;
          if (collection == null) {
            return Container();
          }
          context.read<RssFeedCubit>().initializeNewFeed(
                collectionId: widget.collectionId,
              );

          return PageView(
            controller: _pageController,
            onPageChanged: (page) {
              _currentPage.value = page;
            },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              RssFeedUrlsListWidget(
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                showBottomNavBar: _showBottomNavBar,
              ),
              RssFeedUrlsPreviewListWidget(
                showBottomNavBar: _showBottomNavBar,
                collectionFetchModel: fetchCollection,
                isRootCollection: widget.isRootCollection,
              ),
              RssCollectionsListScreen(
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
              SavedFeedsPreviewListScreen(
                showBottomBar: _showBottomNavBar,
                isRootCollection: true,
                collectionId: fetchCollection.collection!.id + savedFeeds,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getBottomNavBar() {
    return ValueListenableBuilder(
      valueListenable: _showBottomNavBar,
      builder: (context, showBottomBar, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showBottomBar ? null : 0,

          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColourPallette.mystic.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, -1), // changes position of shadow
              ),
            ],
          ),
          // height: showBottomBar ? null : 0,
          child: ValueListenableBuilder(
            valueListenable: _currentPage,
            builder: (context, currentPage, _) {
              return BottomNavigationBar(
                currentIndex: _currentPage.value,
                onTap: (currentIndex) {
                  _currentPage.value = currentIndex;
                  _pageController.jumpToPage(currentIndex);
                },
                type: BottomNavigationBarType.fixed,
                enableFeedback: false,
                backgroundColor: ColourPallette.white,
                elevation: 0,
                selectedItemColor: ColourPallette.black,
                selectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                unselectedItemColor: ColourPallette.black,
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColourPallette.black,
                ),
                items: [
                  CustomBottomNavItem.create(
                    currentPage: _currentPage,
                    label: 'Urls',
                    unSelectedIcon: Icons.webhook_outlined,
                    selectedIcon: Icons.webhook_rounded,
                    index: 0,
                  ),
                  CustomBottomNavItem.create(
                    currentPage: _currentPage,
                    unSelectedIcon: Icons.web_stories_outlined,
                    selectedIcon: Icons.web_stories_rounded,
                    index: 1,
                    label: 'Feed',
                  ),
                  CustomBottomNavItem.create(
                    currentPage: _currentPage,
                    label: 'Collections',
                    // unSelectedIcon: Icons.collections_bookmark_outlined,
                    // selectedIcon: Icons.collections_bookmark_rounded,
                    unSelectedIcon: Icons.folder_outlined,
                    selectedIcon: Icons.folder_rounded,
                    index: 2,
                  ),
                  CustomBottomNavItem.create(
                    currentPage: _currentPage,
                    label: 'Saved',
                    unSelectedIcon: Icons.bookmark_outline,
                    selectedIcon: Icons.bookmark_rounded,
                    index: 3,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _showErrorLoadingWidget(
    void Function() onPress,
  ) {
    return Container(
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
    );
  }

  Widget _showLoadingWidget() {
    return Center(
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
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
