import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:link_vault/core/utils/logger.dart';

class ImageDecodeManager {
  static Future<ui.Image?> decodeImage(Uint8List imageData) async {
    try {
      final decodedImage = await _decodeImage(imageData);

      return decodedImage;
    } catch (e) {
      // Logger.printLog('Error decoding image: $e');
      return null;
    }
  }

  static Future<ui.Image> _decodeImage(Uint8List imageData) async {
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
