import 'package:flutter/services.dart';
import 'package:link_vault/core/utils/logger.dart';

class CustomTabsClient {
  static const MethodChannel _channel = MethodChannel('custom_tabs_client');

  static Future<bool> warmUp() async {
    try {
      await _channel.invokeMethod('warmUp');
      return true;
    } catch (e) {
      Logger.printLog('[customtabs] : Error in warmUp $e');
    }

    return true;
  }

  static Future<bool> mayLaunchUrl(String url) async {
    try {
      await _channel.invokeMethod('mayLaunchUrl', {'url': url});
      return true;
    } catch (e) {
      Logger.printLog('[customtabs] : Error in mayLaunchUrl $e');
    }

    return true;
  }
}
