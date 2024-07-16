import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;
  // final Size widgetSize;
  final BoxFit fit;

  ImagePainter(
    this.image, {
    this.fit = BoxFit.contain,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
      fit: fit,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
