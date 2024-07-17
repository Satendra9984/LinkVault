import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';



Future<Uint8List> compressImage(Uint8List imageBytes) async {
  final compressedBytes = await FlutterImageCompress.compressWithList(
    imageBytes,
    minHeight: 800,
    minWidth: 800,
    quality: 80, // Adjust the quality to your needs (0-100)
  );

  return compressedBytes;
}

Future<void> main_() async {
  final bodyBytes = Uint8List(144966); // Example data

  // Compress the image
  final compressedBytes = await compressImage(bodyBytes);

  // Calculate the size in MB before and after compression
  final originalSizeInMB = bodyBytes.length / (1024 * 1024);
  final compressedSizeInMB = compressedBytes.length / (1024 * 1024);

  print('Original size in MB: $originalSizeInMB');
  print('Compressed size in MB: $compressedSizeInMB');
}
