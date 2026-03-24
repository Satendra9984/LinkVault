import 'package:flutter/material.dart';
import 'package:link_vault/core/res/colours.dart';

class CustomBottomNavItem {
  static BottomNavigationBarItem create({
    required int index,
    required ValueNotifier<int> currentPage,
    required IconData unSelectedIcon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = currentPage.value == index;

    return BottomNavigationBarItem(
      icon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
        child: Icon(
          unSelectedIcon,
          size: 24,
          color: Colors.grey.shade900,
          
        ),
      ),
      activeIcon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56),
          color: isSelected
              ? ColourPallette.freepikLoginImage.withOpacity(0.4)
              : null,
        ),
        child: Icon(
          selectedIcon,
          size: 24,
          color:
              isSelected ? ColourPallette.mountainMeadow : ColourPallette.black,
        ),
      ),
      label: label,
    );
  }
}
