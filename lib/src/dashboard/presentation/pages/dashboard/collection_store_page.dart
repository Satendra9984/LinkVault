import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/collections_list_widget.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/urls_list_widget.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/urls_preview_list.dart';
import 'package:lottie/lottie.dart';

class FolderCollectionPage extends StatefulWidget {
  const FolderCollectionPage({
    required this.collectionId,
    required this.isRootCollection,
    super.key,
  });
  final String collectionId;
  final bool isRootCollection;

  @override
  State<FolderCollectionPage> createState() => _FolderCollectionPageState();
}

class _FolderCollectionPageState extends State<FolderCollectionPage>
    with SingleTickerProviderStateMixin {
  final _showBottomNavBar = ValueNotifier(true);
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

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
      listener: (context, state) {},
      builder: (context, state) {
        final collectionCubit = context.read<CollectionsCubit>();
        final globalUserCubit = context.read<GlobalUserCubit>();

        final fetchCollection = state.collections[widget.collectionId];

        if (fetchCollection == null) {
          context.read<CollectionsCubit>().fetchCollection(
                collectionId: widget.collectionId,
                userId: context.read<GlobalUserCubit>().state.globalUser!.id,
                isRootCollection: widget.isRootCollection,
              );
        }

        if (fetchCollection == null ||
            fetchCollection.collectionFetchingState == LoadingStates.loading) {
          return _getLoadingWidget();
        }

        if (fetchCollection.collectionFetchingState ==
            LoadingStates.errorLoading) {
          return _getErrorWidget(
            collectionCubit: collectionCubit,
            globalUserCubit: globalUserCubit,
          );
        }
        // Logger.printLog('Updated collection store page');

        final collection = fetchCollection.collection;
        if (collection == null) {
          return Container();
        }

        return Scaffold(
          backgroundColor: ColourPallette.white,
          bottomNavigationBar: _getBottomNavigationBar(),
          body: PageView(
            controller: _pageController,
            onPageChanged: (page) => _currentPage.value = page,
            children: [
              UrlsListWidget(
                title: 'Urls',
                collectionFetchModel: fetchCollection,
                showAddCollectionButton: true,
              ),
              CollectionsListWidget(
                collectionFetchModel: fetchCollection,
                showAddCollectionButton: true,
              ),
              UrlsPreviewListWidget(
                showBottomBar: _showBottomNavBar,
                title: 'Urls',
                collectionFetchModel: fetchCollection,
              ),
            ],
          ),
        );
      },
      // ),
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
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
            duration: const Duration(milliseconds: 300),
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
                    _bottomNavBarWidget(
                      label: 'Urls',
                      unSelectedIcon: Icons.link_outlined,
                      selectedIcon: Icons.link_rounded,
                      index: 0,
                    ),
                    _bottomNavBarWidget(
                      label: 'Collections',
                      unSelectedIcon: Icons.collections_bookmark_outlined,
                      selectedIcon: Icons.collections_bookmark_rounded,
                      index: 1,
                    ),
                    _bottomNavBarWidget(
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
    return Scaffold(
      appBar: _getAppBar(title: ''),
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

  Widget _getErrorWidget({
    required CollectionsCubit collectionCubit,
    required GlobalUserCubit globalUserCubit,
  }) {
    return Scaffold(
      appBar: _getAppBar(title: ''),
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
}
