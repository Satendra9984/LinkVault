import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/advance_search/presentation/pages/search_filters_page.dart';
import 'package:link_vault/src/advance_search/presentation/pages/urls_list_page.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              MediaRes.searchSVG,
              height: 18,
              width: 18,
            ),
            const SizedBox(width: 12),
            const Text(
              'Advance Search',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<AdvanceSearchCubit>().searchDB();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: ColourPallette.mountainMeadow.withOpacity(0.25),
                      border: Border.all(color: ColourPallette.mountainMeadow),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.search_rounded,
                          color: ColourPallette.salemgreen,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  _bottomNavBarWidget(
                    label: 'Filters',
                    unSelectedIcon: Icons.filter_list_outlined,
                    selectedIcon: Icons.filter_list_rounded,
                    index: 0,
                  ),
                  _bottomNavBarWidget(
                    label: 'Urls',
                    unSelectedIcon: Icons.link_outlined,
                    selectedIcon: Icons.link_rounded,
                    index: 1,
                  ),
                  _bottomNavBarWidget(
                    label: 'Collections',
                    unSelectedIcon: Icons.collections_bookmark_outlined,
                    selectedIcon: Icons.collections_bookmark_rounded,
                    index: 2,
                  ),
                  _bottomNavBarWidget(
                    unSelectedIcon: Icons.preview_outlined,
                    selectedIcon: Icons.preview_rounded,
                    index: 3,
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
        children: [
          AdvanceSearchFiltersPage(),
          SearchedUrlsListWidget(
            title: 'Urls',
            showAddCollectionButton: false,
          ),
          SearchedUrlsListWidget(
            title: 'Urls',
            showAddCollectionButton: false,
          ),
          SearchedUrlsListWidget(
            title: 'Urls',
            showAddCollectionButton: false,
          ),
        ],
      ),
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
}
