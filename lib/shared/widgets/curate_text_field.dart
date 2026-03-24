import 'package:flutter/material.dart';
import '../../core/theme/color_palette.dart';

class CurateTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? errorText;

  const CurateTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.4),
                ),
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
