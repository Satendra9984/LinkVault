import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart'
    as custom_chrome_tabs;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/services/custom_tabs_client_service.dart';

class CustomTabsService {
  CustomTabsService._();

  static Future<void> launchUrl({
    // required BuildContext context,
    required String url,
    required ThemeData theme,
  }) async {
    final stopWatch = Stopwatch()..start();
    // Logger.printLog(
    //   '[customtabs] : $url ${stopWatch.elapsedMilliseconds}',
    // );

    final uri = Uri.parse(url);

    try {
      // CUSTOM CHROME PREFETCHES AND STORES THE WEBPAGE
      // FOR FASTER WEBPAGE LOADING
      await openUrlInCustomTab(uri: uri, theme: theme);
    } catch (e) {
      // If the URL launch fails, an exception will be thrown. (For example, if no browser app is installed on the Android device.)
      // Logger.printLog(
      //   '[customtabs] : error $e ${stopWatch.elapsedMilliseconds} ',
      // );
      // await custom_chrome_tabs.closeCustomTabs();
      // await CustomTabsClientService.warmUp();

      // await openUrlInCustomTab(uri: uri, theme: theme)
      await url_launcher.launchUrl(uri).catchError(
        (obj) {
          // Logger.printLog(
          //   '[customtabs] : error ${stopWatch.elapsedMilliseconds} ',
          // );
          return true;
        },
      );
    }

    stopWatch.stop();
    Logger.printLog('[customtabs] : stopped ${stopWatch.elapsedMilliseconds}');
  }

  static Future<void> openUrlInCustomTab({
    required Uri uri,
    required ThemeData theme,
  }) async {
    await custom_chrome_tabs.launchUrl(
      uri,
      customTabsOptions: custom_chrome_tabs.CustomTabsOptions(
        colorSchemes: custom_chrome_tabs.CustomTabsColorSchemes.defaults(
          toolbarColor: theme.colorScheme.onPrimary,
          // toolbarColor: Colors.transparent,
        ),
        shareState: custom_chrome_tabs.CustomTabsShareState.on,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: custom_chrome_tabs.CustomTabsCloseButton(
          icon: custom_chrome_tabs.CustomTabsCloseButtonIcons.back,
        ),
        // browser: custom_chrome_tabs.CustomTabsBrowserConfiguration()
      ),
      safariVCOptions: custom_chrome_tabs.SafariViewControllerOptions(
        preferredBarTintColor: theme.colorScheme.onPrimary,
        preferredControlTintColor: theme.colorScheme.onPrimary,
        barCollapsingEnabled: true,
        dismissButtonStyle:
            custom_chrome_tabs.SafariViewControllerDismissButtonStyle.close,
      ),
    );
  }

  static Future<void> getUrlHeadData(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri);

      // Logger.printLog(
      //   '[customtabs]: getUrlHeadData $url statuscode ${response.statusCode}',
      // );
      return;
    } catch (e) {
      // Logger.printLog('[customtabs]: $url Error in getHead $e');
      return;
    }
  }

  static Future<void> getUrlGetData(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      // Logger.printLog(
      //   '[customtabs]: getUrlGetData $url statuscode ${response.statusCode}',
      // );
      return;
    } catch (e) {
      // Logger.printLog('[customtabs]: $url Error in getHead $e');
      return;
    }
  }
}
