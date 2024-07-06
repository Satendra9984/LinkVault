import 'dart:convert';

class StringUtils {
  StringUtils._();

  static String getJsonFormat(dynamic data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
