import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:link_vault/core/utils/logger.dart';

class ImageDecodeManager {
  static Future<ui.Image?> decodeImage(Uint8List imageData) async {
    try {
      final decodedImage = await decodeImage(imageData);

      return decodedImage;
    } catch (e) {
      Logger.printLog('Error decoding image: $e');
      return null;
    }
  }

  static Future<ui.Image> _decodeImage(Uint8List imageData) async {
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}




// class ImageDecodeManager {
//   static Future<ui.Image?> decodeImage(Uint8List imageData) async {
//     final receivePort = ReceivePort();
//     await Isolate.spawn(_decodeIsolate, [receivePort.sendPort, imageData]);
//     final result = await receivePort.first;

//     if (result is ui.Image) {
//       return result;
//     }

//     return null;
//   }

//   static void _decodeIsolate(List<dynamic> message) async {
//     final sendPort = message[0] as SendPort;
//     final imageData = message[1] as Uint8List;

//     final codec = await ui.instantiateImageCodec(imageData);
//     final frame = await codec.getNextFrame();
//     sendPort.send(frame.image);
//   }
// }
