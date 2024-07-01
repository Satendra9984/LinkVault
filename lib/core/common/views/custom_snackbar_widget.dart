// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/enums/snakbar_type.dart';


class CustomSnackbarContent extends StatelessWidget {

  const CustomSnackbarContent({
    required this.snackbarType,
    required this.title,
    required this.subtitle,
    super.key,
  });
  final SnackbarType snackbarType;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(snackbarType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: ColourPallette.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: ColourPallette.white,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(SnackbarType snackbarType) {
    return switch (snackbarType) {
      SnackbarType.success => ColourPallette.success,
      SnackbarType.information => ColourPallette.information,
      SnackbarType.warning => ColourPallette.warning,
      _ => ColourPallette.error,
    };
  }
}

class CustomSnackbarWidget extends StatelessWidget {
  const CustomSnackbarWidget({
    required this.snackbarType,
    required this.title,
    required this.subtitle,
    super.key,
  });
  final SnackbarType snackbarType;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(snackbarType);

    return ListTile(      
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: backgroundColor,
      selectedColor: backgroundColor,
      leading: Icon(
        _getIcon(snackbarType),
        size: 40,
        color: ColourPallette.white,
        ),
      title: Text(
        title,
        style: const TextStyle(
          color: ColourPallette.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: ColourPallette.white,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }

  IconData _getIcon(SnackbarType snackbarType) {
    return switch (snackbarType) {
      SnackbarType.success => Icons.check_circle_rounded,
      SnackbarType.information => Icons.info_rounded,
      SnackbarType.warning => Icons.warning_rounded,
      _ => Icons.error_rounded,
    };
  }

  Color _getBackgroundColor(SnackbarType snackbarType) {
    return switch (snackbarType) {
      SnackbarType.success => ColourPallette.success,
      SnackbarType.information => ColourPallette.information,
      SnackbarType.warning => ColourPallette.warning,
      _ => ColourPallette.error,
    };
  }
}
