import 'package:flutter/material.dart';
import '../../core/theme/color_palette.dart';

class CurateCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double elevation;

  const CurateCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? AppColors.surface,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
