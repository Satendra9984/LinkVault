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

      // Logger.prfinalLog('Image dimensions: ${width}x${height}');

      return Size(width, height);
    } else {
      Logger.printLog('Failed to decode image');
      return null;
    }
  }

  static Future<Uint8List?> compressImage(
    Uint8List imageBytes, {
    required int quality,
    required bool autofillPng,
    (int r, int g, int b)? autofillColor,
  }) async {
    final imageSize = getImageDimFromUintData(imageBytes);

    if (imageSize == null) return null;

    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Check if the image has an alpha channel
    final hasAlpha = image.numChannels == 4;

    // Compress while preserving transparency if it has alpha channel
    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: quality,
      format:
          hasAlpha && autofillPng ? CompressFormat.png : CompressFormat.jpeg,
      keepExif: true,
    );

    return Uint8List.fromList(compressedBytes);
  }

  static Uint8List extractLowerHalf(
    Uint8List imageData, {
    required double fractionLowerHeight,
  }) {
    // Decode the image
    final originalImage = img.decodeImage(imageData)!;

    // Get the dimensions of the original image
    final width = originalImage.width;
    final height = originalImage.height;

    // Extract the lower half
    final lowerHalf = img.copyCrop(
      originalImage,
      x: 0,
      y: height ~/ fractionLowerHeight,
      width: width,
      height: height ~/ fractionLowerHeight,
    );

    // Encode the lower half back to Ufinal8List
    final lowerHalfData = Uint8List.fromList(img.encodePng(lowerHalf));
    return lowerHalfData;
  }

  static int averageBrightness(Uint8List imageData) {
    // Decode the image
    final image = img.decodeImage(imageData)!;

    var totalBrightness = 0;
    var pixelCount = 0;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        // Get the pixel color
        final pixel = image.getPixel(x, y);

        // Get the brightness (grayscale value)
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // Average brightness
        final brightness = (r + g + b) ~/ 3;

        totalBrightness += brightness;
        pixelCount++;
      }
    }
    return totalBrightness ~/ pixelCount;
  }

  String decideTextColor(int averageBrightness) {
    // Threshold for deciding text color
    const threshold = 128; // You may adjust this value

    if (averageBrightness > threshold) {
      return 'black';
    } else {
      return 'white';
    }
  }
}
