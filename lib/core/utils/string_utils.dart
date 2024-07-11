import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:html_unescape/html_unescape.dart';

class StringUtils {
  StringUtils._();

  static String getJsonFormat(dynamic data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static String? convertHtmlStringIntoString(String? htmlString) {
    if (htmlString == null) return null;

    final plainText = HtmlUnescape()
        .convert(htmlString)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return plainText;
  }

  static String getUnicodeString(String uncodedString) {
    try {
      final encoded = utf8.encode(uncodedString);
      final decoded = utf8.decode(encoded, allowMalformed: true);
      return decoded;
    } catch (e) {
      return uncodedString;
    }
  }

  // Function to convert Uint8List to Base64 string
  static String? convertUint8ListToBase64(Uint8List? data) {
    if (data == null) return null;
    return base64Encode(data);
  }

  static Uint8List? compressString(String data) {
    final encodedData = utf8.encode(data);
    return GZipEncoder().encode(encodedData) as Uint8List?;
  }

// Function to convert Base64 string back to Uint8List
  static Uint8List? convertBase64ToUint8List(String? base64String) {
    if (base64String == null) {
      return null;
    }
    return base64Decode(base64String);
  }

  static String decompressString(Uint8List compressedData) {
    final decompressedData = GZipDecoder().decodeBytes(compressedData);
    return utf8.decode(decompressedData);
  }
}
