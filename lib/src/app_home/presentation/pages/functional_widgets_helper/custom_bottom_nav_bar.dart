import 'package:flutter/material.dart';
import 'package:link_vault/core/common/res/colours.dart';

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
      icon: Icon(unSelectedIcon),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? ColourPallette.salemgreen.withOpacity(0.4) : null,
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
