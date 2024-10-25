import 'package:flutter/services.dart';
// import 'package:link_vault/core/utils/logger.dart';

class CustomTabsClientService {
  CustomTabsClientService._();

  static const MethodChannel _channel = MethodChannel('custom_tabs_client');

  static Future<bool> warmUp() async {
    try {
      await _channel.invokeMethod('warmUp');
      // Logger.printLog('[customtabs] : chromeTab warmedup');

      return true;
    } catch (e) {
      // Logger.printLog('[customtabs] : Error in warmUp $e');
    }

    return false;
  }

  static Future<bool> mayLaunchUrl(String url) async {
    try {
      await _channel.invokeMethod('mayLaunchUrl', {'url': url});
      // Logger.printLog('[customtabs] : $url mayLaunchUrl ');

      return true;
    } catch (e) {
      // Logger.printLog('[customtabs] : $url Error in mayLaunchUrl $e');
    }

    return false;
  }
}
