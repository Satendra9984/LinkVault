import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

part 'image_with_bytes.g.dart';

@collection
class ImagesByteData {
  ImagesByteData({
    required this.imageUrl,
    required this.imageBytes,
  });

  factory ImagesByteData.fromBytes({
    required String imageUrl,
    required Uint8List bytes,
  }) {
    return ImagesByteData(
      imageUrl: imageUrl,
      imageBytes: bytes,
    );
  }

  Id id = Isar.autoIncrement;

  String imageUrl;

  List<int> imageBytes;
}
