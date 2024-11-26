import 'package:flutter/material.dart';

class BottomSheetOption extends StatelessWidget {

  const BottomSheetOption({
    required this.title, required this.onTap, super.key,
    this.leadingIcon,
    this.leadingWidgt,
    this.trailing,
  });
  final IconData? leadingIcon;
  final Widget? leadingWidgt;
  final Widget title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: leadingWidgt ?? Icon(leadingIcon),
      title: title,
      trailing: trailing,
    );
  }
}
