import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/webview_cubit/webviews_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_bottom_nav_bar.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/services/custom_tabs_client_service.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_collections_list_screen.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_url_favicon_list_screen.dart';
import 'package:lottie/lottie.dart';

class CollectionStorePage extends StatefulWidget {
  const CollectionStorePage({
    required this.collectionId,
    required this.isRootCollection,
    required this.appBarLeadingIcon,
    super.key,
  });
  final String collectionId;
  final bool isRootCollection;
  final Widget appBarLeadingIcon;

  @override
  State<CollectionStorePage> createState() => _CollectionStorePageState();
}

class _CollectionStorePageState extends State<CollectionStorePage>
    with AutomaticKeepAliveClientMixin {
  // TODO : SEE THE POSSIBILITIES OF AUTOMATIC KEEP ALIVE BUT
  /* WEBVIEW WILL CREATE PROBLEM AS IT WILL COMSUME MEMORY
     WE CAN MAKE THE KEEP-ALIVE DYNAMIC IN WEB-VIEW SCREEN
     SO THAT WHEN THIS-SCREEN GOES OUT-OF-VISIBILITY SO WILL 
     DISTROY THE WEBVIEW BUT CAN KEEP THE OTHER VIEWS LIKE 
     URLFAVICONLIST, COLLECTIONSLIST SCREENS
  */

  final _showBottomNavBar = ValueNotifier(true);
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );

    CustomTabsClientService.warmUp();

    context.read<WebviewsCubit>().createWebView(
          context.read<GlobalUserCubit>().getGlobalUser()!.id,
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
      bottomNavigationBar: _getBottomNavigationBar(),
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
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
            onPageChanged: (page) => _currentPage.value = page,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DashboardUrlFaviconListScreen(
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                showAddUrlButton: true,
                showBottomNavBar: _showBottomNavBar,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
              DashboardCollectionsListScreen(
                collectionModel: fetchCollection.collection!,
                isRootCollection: widget.isRootCollection,
                showAddCollectionButton: true,
                appBarLeadingIcon: widget.appBarLeadingIcon,
              ),
            ],
          );
        },
        // ),
      ),
    );
  }

  Widget _getBottomNavigationBar() {
    return ValueListenableBuilder(
      valueListenable: _showBottomNavBar,
      builder: (context, showBottomBar, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          height: showBottomBar ? null : 0,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade200,
                width: 0.5,
              ),
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: ColourPallette.mystic.withOpacity(0.5),
            //     spreadRadius: 4,
            //     blurRadius: 10,
            //     offset: const Offset(0, -1), // changes position of shadow
            //   ),
            // ],
          ),
          child: ValueListenableBuilder(
            valueListenable: _currentPage,
            builder: (context, currentPage, _) {
              return BottomNavigationBar(
                currentIndex: _currentPage.value,
                onTap: (currentIndex) {
                  _currentPage.value = currentIndex;
                  _pageController.jumpToPage(currentIndex);
                },
                enableFeedback: false,
                type: BottomNavigationBarType.fixed,
                backgroundColor: ColourPallette.white,
                elevation: 0.0,
                selectedItemColor: ColourPallette.black,
                selectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                unselectedItemColor: ColourPallette.black,
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
                    label: 'Collections',
                    unSelectedIcon: Icons.folder_outlined,
                    selectedIcon: Icons.folder_rounded,
                    index: 1,
                  ),
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

  @override
  bool get wantKeepAlive => true;
}
