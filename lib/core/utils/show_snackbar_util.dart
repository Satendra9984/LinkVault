import 'package:flutter/material.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_snackbar_widget.dart';
import 'package:link_vault/src/common/repository_layer/enums/snakbar_type.dart';

void showSnackbar({
  required BuildContext context,
  required String title,
  required String subtitle,
  SnackbarType snackbarType = SnackbarType.failure,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      duration: const Duration(seconds: 3),
      content: CustomSnackbarWidget(
        snackbarType: snackbarType,
        title: title,
        subtitle: subtitle,
      ),
    ),
  );
}
