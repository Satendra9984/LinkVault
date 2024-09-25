import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/common/collections_list_widget.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/common/rss_urls_list_widget.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/common/rss_feed_preview_list.dart';
import 'package:lottie/lottie.dart';

class RssFeedFolderCollectionPage extends StatefulWidget {
  const RssFeedFolderCollectionPage({
    required this.collectionId,
    required this.isRootCollection,
    super.key,
  });
  final String collectionId;
  final bool isRootCollection;

  @override
  State<RssFeedFolderCollectionPage> createState() =>
      _RssFeedFolderCollectionPageState();
}

class _RssFeedFolderCollectionPageState
    extends State<RssFeedFolderCollectionPage>
    with SingleTickerProviderStateMixin {
  // late final ScrollController _scrollController;
  final _showBottomNavBar = ValueNotifier(true);
  final PageController _pageController = PageController();
  // late final TabController _pageController;

  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
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
    return BlocConsumer<CollectionsCubit, CollectionsState>(
      listener: (context, state) {
        // [TODO]: implement listener
      },
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
                collectionName: 'RssFeeds',
              );
        }

        if (fetchCollection == null ||
            fetchCollection.collectionFetchingState == LoadingStates.loading) {
          return Scaffold(
            // appBar: _getAppBar(title: ''),
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

        if (fetchCollection.collectionFetchingState ==
            LoadingStates.errorLoading) {
          return Scaffold(
            // appBar: _getAppBar(title: ''),
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
                    'Something went wrong while fetching the collection from the database.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomElevatedButton(
                    text: 'Try Again',
                    onPressed: () => collectionCubit.fetchCollection(
                      collectionId: widget.collectionId,
                      userId: globalUserCubit.state.globalUser!.id,
                      isRootCollection: widget.isRootCollection,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Logger.printLog('Updated collection store page');

        final collection = fetchCollection.collection;
        if (collection == null) {
          return Container();
        }

        return Scaffold(
          backgroundColor: ColourPallette.white,
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: ColourPallette.mystic.withOpacity(0.5),
                  spreadRadius: 4,
                  blurRadius: 16,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: ValueListenableBuilder(
              valueListenable: _showBottomNavBar,
              builder: (context, showBottomBar, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: showBottomBar ? null : 0,
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
                          fontSize: 16,
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
                          _bottomNavBarWidget(
                            label: 'Urls',
                            unSelectedIcon: Icons.link_outlined,
                            selectedIcon: Icons.link_rounded,
                            index: 0,
                          ),
                          _bottomNavBarWidget(
                            unSelectedIcon: Icons.list_outlined,
                            selectedIcon: Icons.list_alt,
                            index: 1,
                            label: 'Feeds',
                          ),
                          _bottomNavBarWidget(
                            label: 'Collections',
                            unSelectedIcon: Icons.collections_bookmark_outlined,
                            selectedIcon: Icons.collections_bookmark_rounded,
                            index: 2,
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              _currentPage.value = page;
            },
            children: [
              RssFeedUrlsListWidget(
                title: 'Urls',
                collectionFetchModel: fetchCollection,
                showAddCollectionButton: true,
              ),
              UrlsPreviewListWidget(
                showBottomBar: _showBottomNavBar,
                title: 'Feeds',
                collectionFetchModel: fetchCollection,
              ),
              CollectionsListWidget(
                collectionFetchModel: fetchCollection,
                showAddCollectionButton: true,
              ),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _bottomNavBarWidget({
    required int index,
    required IconData unSelectedIcon,
    required IconData selectedIcon,
    required String label,
  }) {
    final selected = _currentPage.value == index;
    return BottomNavigationBarItem(
      icon: Icon(
        unSelectedIcon,
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          // shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          color: selected ? ColourPallette.salemgreen.withOpacity(0.4) : null,
        ),
        child: Icon(
          selectedIcon,
          size: 24,
          color: ColourPallette.black,
        ),
      ),
      label: label,
    );
  }

  PreferredSize _getAppBar({
    required String title,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (context, isVisible, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isVisible != 2 ? kToolbarHeight + 16 : 24.0,
            child: AppBar(
              // backgroundColor: Colors.transparent,
              surfaceTintColor: ColourPallette.mystic,
              title: Row(
                children: [
                  SvgPicture.asset(
                    MediaRes.newsletterSVG,
                    height: 18,
                    width: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
