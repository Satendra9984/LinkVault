import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:link_vault/core/utils/logger.dart';

class ImageUtils {
  ImageUtils._();

  static Size? getImageDimFromUintData(Uint8List imageData) {
    // Decode the image
    final image = img.decodeImage(imageData);

    if (image != null) {
      // Get image dimensions
      final width = image.width.toDouble();
      final height = image.height.toDouble();

      // Logger.printLog('Image dimensions: ${width}x${height}');

      return Size(width, height);
    } else {
      Logger.printLog('Failed to decode image');
      return null;
    }
  }

  static Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    final imageSize = getImageDimFromUintData(imageBytes);

    if (imageSize == null) return null;

    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: imageSize.height.toInt(),
      minWidth: imageSize.width.toInt(),
      quality: 75, // Adjust the quality to your needs (0-100)
    );

    return compressedBytes;
  }
}
