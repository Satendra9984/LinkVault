import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart'
    as custom_chrome_tabs;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class CustomTabsService {
  CustomTabsService._();

  static Future<void> launchUrl({
    // required BuildContext context,
    required String url,
    required ThemeData theme,
  }) async {
    final stopWatch = Stopwatch()..start();
    Logger.printLog(
      '[url] : ${url} ${stopWatch.elapsedMilliseconds}',
    );

    final uri = Uri.parse(url);

    try {
      // CUSTOM CHROME PREFETCHES AND STORES THE WEBPAGE
      // FOR FASTER WEBPAGE LOADING
      await custom_chrome_tabs
          .launchUrl(
        uri,
        customTabsOptions: custom_chrome_tabs.CustomTabsOptions(
          colorSchemes: custom_chrome_tabs.CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.onPrimary,
          ),
          shareState: custom_chrome_tabs.CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: custom_chrome_tabs.CustomTabsCloseButton(
            icon: custom_chrome_tabs.CustomTabsCloseButtonIcons.back,
          ),
          // partial: const custom_chrome_tabs.PartialCustomTabsConfiguration(
          //   initialHeight: 180,
          //   activityHeightResizeBehavior:
          //       custom_chrome_tabs.CustomTabsActivityHeightResizeBehavior.new(),
          // ),
        ),
        safariVCOptions: custom_chrome_tabs.SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface,
          preferredControlTintColor: theme.colorScheme.onSurface,
          barCollapsingEnabled: true,
          dismissButtonStyle:
              custom_chrome_tabs.SafariViewControllerDismissButtonStyle.close,
        ),
      )
          .catchError(
        (_) async {
          // debugPrint(e.toString());
          if (await url_launcher.canLaunchUrl(uri)) {
            await url_launcher.launchUrl(uri);
          }
        },
      );
    } catch (e) {
      // If the URL launch fails, an exception will be thrown. (For example, if no browser app is installed on the Android device.)
    }

    stopWatch.stop();
    Logger.printLog('[url] : stopped ${stopWatch.elapsedMilliseconds}');
  }

  static Future<void> getUrlHeadData(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri);

      Logger.printLog('[customtabs]: statuscode ${response.statusCode}');
      return;
    } catch (e) {
      Logger.printLog('[customtabs]: Error in getHead $e');
      return;
    }
  }
}
