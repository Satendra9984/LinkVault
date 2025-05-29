import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:link_vault/core/utils/string_utils.dart';

part 'url_image.g.dart';

@collection
class UrlImage {
  UrlImage({
    required this.imageUrl,
    required this.base64ImageBytes,
    this.id,
  });

  factory UrlImage.fromBytes({
    required String imageUrl,
    required Uint8List bytes,
  }) {
    return UrlImage(
      imageUrl: imageUrl,
      base64ImageBytes: StringUtils.convertUint8ListToBase64(bytes)??'',
    );
  }

  final Id? id;
  
  @Index(unique: true, replace: true)
  String imageUrl;

  String base64ImageBytes;
}
