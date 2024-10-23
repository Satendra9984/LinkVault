import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart'
    as customChromeTabs;
import 'package:link_vault/core/utils/logger.dart';

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

    // CUSTOM CHROME PREFETCHES AND STORES THE WEBPAGE
    // FOR FASTER WEBPAGE LOADING
    await customChromeTabs.launchUrl(
      uri,
      customTabsOptions: customChromeTabs.CustomTabsOptions(
        colorSchemes: customChromeTabs.CustomTabsColorSchemes.defaults(
          toolbarColor: theme.colorScheme.onPrimary,
        ),
        shareState: customChromeTabs.CustomTabsShareState.on,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: customChromeTabs.CustomTabsCloseButton(
          icon: customChromeTabs.CustomTabsCloseButtonIcons.back,
        ),
      ),
      safariVCOptions: customChromeTabs.SafariViewControllerOptions(
        preferredBarTintColor: theme.colorScheme.surface,
        preferredControlTintColor: theme.colorScheme.onSurface,
        barCollapsingEnabled: true,
        dismissButtonStyle:
            customChromeTabs.SafariViewControllerDismissButtonStyle.close,
      ),
    );

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
