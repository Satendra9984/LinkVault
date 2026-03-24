import 'package:flutter/material.dart';
import 'package:link_vault/core/res/colours.dart';

class FilterPopupMenuButton extends StatelessWidget {

  const FilterPopupMenuButton({
    required this.menuItems, required this.icon, super.key,
    this.color = ColourPallette.white,
    this.elevation = 8,
  });
  final List<PopupMenuItem<dynamic>> menuItems;
  final Widget icon;
  final Color color;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: elevation,
      icon: icon,
      itemBuilder: (ctx) => menuItems,
    );
  }
}
