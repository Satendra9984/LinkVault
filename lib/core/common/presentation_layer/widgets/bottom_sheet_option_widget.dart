import 'package:flutter/material.dart';

class BottomSheetOption extends StatelessWidget {
  final IconData leadingIcon;
  final Widget title;
  final VoidCallback onTap;
  final Widget? trailing;

  const BottomSheetOption({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(leadingIcon),
      title: title,
      trailing: trailing,
    );
  }
}
