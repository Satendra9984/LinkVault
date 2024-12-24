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
import 'package:link_vault/src/recents/presentation/pages/recents_url_favicon_list_screen.dart';
import 'package:lottie/lottie.dart';

class RecentsStorePage extends StatefulWidget {
  const RecentsStorePage({
    required this.collectionId,
    required this.isRootCollection,
    required this.appBarLeadingIcon,
    super.key,
  });
  final String collectionId;
  final bool isRootCollection;
  final Widget appBarLeadingIcon;

  @override
  State<RecentsStorePage> createState() => _RecentsStorePageState();
}

class _RecentsStorePageState extends State<RecentsStorePage>
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
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
        builder: (context, state) {
          // final size = MediaQuery.of(context).size;
          final collectionCubit = context.read<CollectionsCubit>();
          final globalUserCubit = context.read<GlobalUserCubit>();

          final fetchCollection = state.collections[widget.collectionId];

          if (fetchCollection == null) {
            context.read<CollectionsCubit>().fetchCollection(
                  prentCollectionId: widget.collectionId,
                  userId: context.read<GlobalUserCubit>().state.globalUser!.id,
                  isRootCollection: widget.isRootCollection,
                  collectionName: 'Recents',
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

          final collection = fetchCollection.collection;
          // Logger.printLog(
          //     '[RECENT] : Updated recentstore collection store page, ${collection?.urls}');
          if (collection == null) {
            return Container();
          }

          return RecentsUrlFaviconListScreen(
            collectionModel: collection,
            isRootCollection: widget.isRootCollection,
            showAddUrlButton: false,
            appBarLeadingIcon: widget.appBarLeadingIcon,
            showBottomNavBar: _showBottomNavBar,
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
                      unSelectedIcon: Icons.webhook_outlined,
                      selectedIcon: Icons.webhook_rounded,
                      index: 0,
                    ),
                    // CustomBottomNavItem.create(
                    //   currentPage: _currentPage,
                    //   label: 'Collections',
                    //   unSelectedIcon: Icons.folder_outlined,
                    //   selectedIcon: Icons.folder_rounded,
                    //   index: 1,
                    // ),
                    // CustomBottomNavItem.create(
                    //   currentPage: _currentPage,
                    //   unSelectedIcon: Icons.dynamic_feed_outlined,
                    //   selectedIcon: Icons.dynamic_feed,
                    //   index: 2,
                    //   label: 'Previews',
                    // ),
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
              prentCollectionId: widget.collectionId,
              userId: globalUserCubit.state.globalUser!.id,
              isRootCollection: widget.isRootCollection,
            ),
          ),
        ],
      ),
    );
  }
}
