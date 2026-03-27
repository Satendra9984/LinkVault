import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Persistent bottom-navigation scaffold for the 4 main tabs:
/// Home  ·  Collections  ·  Search  ·  Profile
///
/// Uses [StatefulNavigationShell] (via [StatefulShellRoute]) so each tab
/// retains its own navigator/state when switching.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_TabItem> _tabs = [
    _TabItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
      route: '/',
    ),
    _TabItem(
      icon: Icon(Icons.grid_view_outlined),
      activeIcon: Icon(Icons.grid_view_rounded),
      label: 'Collections',
      route: '/collections',
    ),
    _TabItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search_rounded),
      label: 'Search',
      route: '/search',
    ),
    _TabItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profile',
      route: '/profile',
    ),
  ];

  void _onTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    if (index == navigationShell.currentIndex) {
      // Tap the active tab again → pop sub-routes back to root of that branch.
      navigationShell.goBranch(index, initialLocation: true);
    } else {
      navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        indicatorColor: cs.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: _tabs.map((tab) {
          return NavigationDestination(
            icon: tab.icon,
            selectedIcon: IconTheme(
              data: IconThemeData(color: cs.primary),
              child: tab.activeIcon,
            ),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final Widget icon;
  final Widget activeIcon;
  final String label;
  final String route;
}
