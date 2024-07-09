import 'dart:convert';

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
      final decoded =
          utf8.decode(encoded, allowMalformed: true);
      return decoded;
    } catch (e) {
      return uncodedString;
    }
  }
}
