// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:link_vault/core/common/res/colours.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final double fontSize;
  final Widget? icon;
  final Color? backgroundColor;

  const CustomElevatedButton({
    required this.text, required this.onPressed, super.key,
    this.color,
    this.textColor,
    this.borderRadius = 12.0,
    this.fontSize = 16.0,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon ?? const Text(''),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? ColourPallette.salemgreen,
        // foregroundColor:  backgroundColor ?? ColourPallette.salemgreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      label: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
