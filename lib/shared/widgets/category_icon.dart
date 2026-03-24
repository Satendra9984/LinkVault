import 'package:flutter/material.dart';
import '../../core/theme/color_palette.dart';

class CategoryIcon extends StatelessWidget {
  final String
      icon; // Currently using String, but will likely map to IconData later
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const CategoryIcon({
    super.key,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Text(icon, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}
