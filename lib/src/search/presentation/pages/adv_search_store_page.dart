import 'package:flutter/material.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_bottom_nav_bar.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/src/search/presentation/pages/adv_search_collections_list_page.dart';
import 'package:link_vault/src/search/presentation/pages/adv_search_urls_list_page.dart';
import 'package:link_vault/src/search/presentation/pages/search_filters_page.dart';
import 'package:link_vault/src/search/presentation/pages/urls_preview_page.dart';

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
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.only(top: 4, bottom: 4),
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
                // _pageController.jumpToPage(currentIndex);
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
                  label: 'Filters',
                  unSelectedIcon: Icons.filter_alt_outlined,
                  selectedIcon: Icons.filter_alt_rounded,
                  index: 0,
                ),
                CustomBottomNavItem.create(
                  currentPage: _currentPage,
                  label: 'Urls',
                  unSelectedIcon: Icons.webhook_outlined,
                  selectedIcon: Icons.webhook_rounded,
                  index: 1,
                ),
                CustomBottomNavItem.create(
                  currentPage: _currentPage,
                  label: 'Collections',
                  unSelectedIcon: Icons.folder_outlined,
                  selectedIcon: Icons.folder_rounded,
                  index: 2,
                ),
                CustomBottomNavItem.create(
                  currentPage: _currentPage,
                  unSelectedIcon: Icons.dynamic_feed_outlined,
                  selectedIcon: Icons.dynamic_feed,
                  index: 3,
                  label: 'Previews',
                ),
              ],
            );
          },
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
