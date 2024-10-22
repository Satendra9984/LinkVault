import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/app_home/presentation/pages/functional_widgets_helper/custom_bottom_nav_bar.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/dashboard_collections_list_screen.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/dashboard_url_favicon_list_screen.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/dashboard_urls_preview_list_screen.dart';
import 'package:lottie/lottie.dart';

class FavouriteFolderCollectionPage extends StatefulWidget {
  const FavouriteFolderCollectionPage({
    required this.collectionId,
    required this.isRootCollection,
    required this.appBarLeadingIcon,
    super.key,
  });
  final String collectionId;
  final bool isRootCollection;
  final Widget appBarLeadingIcon;

  @override
  State<FavouriteFolderCollectionPage> createState() =>
      _FavouriteFolderCollectionPageState();
}

class _FavouriteFolderCollectionPageState
    extends State<FavouriteFolderCollectionPage>
    with SingleTickerProviderStateMixin {
  // late final ScrollController _scrollController;
  final _showBottomNavBar = ValueNotifier(true);
  final PageController _pageController = PageController();
  // late final TabController _pageController;

  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: ColourPallette.white,
      bottomNavigationBar: _getBottomNavigationBar(),
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
                  collectionName: 'Favourites',
                );
          }

          if (fetchCollection == null ||
              fetchCollection.collectionFetchingState ==
                  LoadingStates.loading) {
            return _getLoadingWidget();
          }

          if (fetchCollection.collectionFetchingState ==
                  LoadingStates.errorLoading ||
              fetchCollection.collection == null) {
            return _getErrorWidget(
              collectionCubit: collectionCubit,
              globalUserCubit: globalUserCubit,
            );
          }
          // // Logger.printLog('Updated collection store page');

          final collection = fetchCollection.collection;
          if (collection == null) {
            return Container();
          }

          return PageView(
            controller: _pageController,
            onPageChanged: (page) {
              _currentPage.value = page;
            },
            children: [
              DashboardUrlFaviconListScreen(
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                showAddUrlButton: false,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
              DashboardCollectionsListScreen(
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                showAddCollectionButton: false,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
              UrlsPreviewListScreen(
                showBottomBar: _showBottomNavBar,
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getBottomNavigationBar() {
    return Container(
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
            duration: const Duration(milliseconds: 100),
            height: showBottomBar ? null : 0,
            child: ValueListenableBuilder(
              valueListenable: _currentPage,
              builder: (context, currentPage, _) {
                return BottomNavigationBar(
                  currentIndex: _currentPage.value,
                  onTap: (currentIndex) {
                    _currentPage.value = currentIndex;
                    // _pageController.jumpToPage(currentIndex);
                    _pageController.jumpToPage(currentIndex);
                  },
                  enableFeedback: false,
                  type: BottomNavigationBarType.fixed,
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
                    CustomBottomNavItem.create(
                      currentPage: _currentPage,
                      label: 'Urls',
                      unSelectedIcon: Icons.link_outlined,
                      selectedIcon: Icons.link_rounded,
                      index: 0,
                    ),
                    CustomBottomNavItem.create(
                      currentPage: _currentPage,
                      label: 'Collections',
                      unSelectedIcon: Icons.collections_bookmark_outlined,
                      selectedIcon: Icons.collections_bookmark_rounded,
                      index: 1,
                    ),
                    CustomBottomNavItem.create(
                      currentPage: _currentPage,
                      unSelectedIcon: Icons.preview_outlined,
                      selectedIcon: Icons.preview_rounded,
                      index: 2,
                      label: 'Previews',
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getLoadingWidget() {
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

  Widget _getErrorWidget({
    required CollectionsCubit collectionCubit,
    required GlobalUserCubit globalUserCubit,
  }) {
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
    );
  }
}
