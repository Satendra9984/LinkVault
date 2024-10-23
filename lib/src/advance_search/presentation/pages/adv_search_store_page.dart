import 'package:flutter/material.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/advance_search/presentation/pages/adv_search_collections_list_page.dart';
import 'package:link_vault/src/advance_search/presentation/pages/search_filters_page.dart';
import 'package:link_vault/src/advance_search/presentation/pages/urls_list_page.dart';
import 'package:link_vault/src/advance_search/presentation/pages/urls_preview_page.dart';
import 'package:link_vault/src/app_home/presentation/pages/functional_widgets_helper/custom_bottom_nav_bar.dart';

class AdvanceSearchPage extends StatefulWidget {
  const AdvanceSearchPage({super.key});

  @override
  State<AdvanceSearchPage> createState() => _AdvanceSearchPageState();
}

class _AdvanceSearchPageState extends State<AdvanceSearchPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                showUnselectedLabels: true,
                showSelectedLabels: true,
                items: [
                  CustomBottomNavItem.create(
                    currentPage: _currentPage,
                    label: 'Filters',
                    unSelectedIcon: Icons.filter_alt_outlined ,
                    selectedIcon: Icons.filter_alt_rounded,
                    index: 0,
                  ),
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
                  CustomBottomNavItem.create(
                    currentPage: _currentPage,
                    unSelectedIcon: Icons.dynamic_feed_outlined,
                    selectedIcon: Icons.dynamic_feed,
                    index: 2,
                    label: 'Previews',
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          _currentPage.value = page;
        },
        children: const [
          AdvanceSearchFiltersPage(),
          SearchedUrlsListWidget(),
          SearchedCollectionsListWidget(),
          SearchedUrlsPreviewListWidget(),
        ],
      ),
    );
  }
}
