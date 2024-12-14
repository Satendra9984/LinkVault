import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/webview_cubit/webviews_cubit.dart';
import 'package:link_vault/core/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/logger.dart';
// import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart'; // Add permission_handler dependency

class DashboardWebView extends StatefulWidget {
  const DashboardWebView({required this.url, super.key});

  final String url;

  @override
  State<DashboardWebView> createState() => _DashboardWebViewState();
}

class _DashboardWebViewState extends State<DashboardWebView> {
  final GlobalKey webViewKey = GlobalKey();
  final _showAppBar = ValueNotifier(true);
  final _statusBarBgColorDefault = ValueNotifier<Color?>(null);

  InAppWebViewController? webViewController;
  final _canWebviewGoBack = ValueNotifier(false);
  bool _historyCleared = false;

  InAppWebViewSettings settings = InAppWebViewSettings(
    useOnLoadResource: true,
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;
  // final _url = ValueNotifier<String?>(null);
  final _prevBackListUrl = ValueNotifier<List<WebHistoryItem>?>(null);
  final _progress = ValueNotifier<double>(0);
  final _isDarkMode = ValueNotifier(false);
  final userSwipedSystemStatusBar = ValueNotifier(0);

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );

    super.initState();

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              // TODO : COULD USE AS TRIGGER FOR OPTIONS
              if (defaultTargetPlatform == TargetPlatform.android) {
                await webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                await webViewController?.loadUrl(
                  urlRequest:
                      URLRequest(url: await webViewController?.getUrl()),
                );
              }
            },
          );
  }

  Future<void> _updateCanBack() async {
    try {
      if (webViewController == null) {
        // Logger.printLog('WEBVIEW CONTROLLER IS NULL');
        return;
      }

      final webviewCanGoBack = await webViewController!.canGoBack();
      if (webviewCanGoBack == false || _prevBackListUrl.value == null) {
        _canWebviewGoBack.value = webviewCanGoBack;
        Logger.printLog(
          'webviewCanGoBack $webviewCanGoBack , prevValueList ${_prevBackListUrl.value == null}',
        );
        return;
      }

      await webViewController?.getCopyBackForwardList().then(
        (webhis) {
          if (webhis == null || webhis.list == null) {
            return;
          }
          final currentBackList = webhis.list!;
          final prevBackList = _prevBackListUrl.value!;

          if ((currentBackList.length - prevBackList.length) <= 1) {
            _canWebviewGoBack.value = false;
          } else {
            _canWebviewGoBack.value = true;
          }

          Logger.printLog(
            'webviewCanGoBack IN GETCOPYBACKFORWARDLIST $webviewCanGoBack ',
          );
        },
      );
    } catch (e) {
      Logger.printLog('Error in _updateCanBack: $e');
    }
  }

  Future<void> _updateStatusBarColorFromTop() async {
    try {
      // Evaluate JavaScript and fetch background colors
      final colorValue = await webViewController?.evaluateJavascript(
        source: '''
                  (function() {
                      function getBackgroundColor(element) {
                          while (element) {
                              const style = window.getComputedStyle(element);
                              if (style.backgroundColor && style.backgroundColor !== 'transparent' && style.backgroundColor !== 'rgba(0, 0, 0, 0)') {
                                  return style.backgroundColor;
                              }
                              element = element.parentElement;
                          }
                          return null;
                      }

                      const samplePoints = [0, window.innerWidth * 0.25, window.innerWidth * 0.5, window.innerWidth * 0.75, window.innerWidth - 1];
                      const colors = samplePoints.map(x => {
                          const element = document.elementFromPoint(x, 0);
                          return element ? getBackgroundColor(element) : null;
                      });

                      const prefersDarkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

                      return JSON.stringify({
                          colors: colors,
                          prefersDarkMode: prefersDarkMode
                      });
                  })();
               ''',
      );

      if (colorValue != null && colorValue != 'null') {
        // Parse the JSON result
        final result =
            jsonDecode(colorValue.toString()) as Map<String, dynamic>;
        final colors = result['colors'] as List<dynamic>;
        final prefersDarkMode = result['prefersDarkMode'] as bool;

        // Convert sampled colors to Flutter Color objects and filter out null/transparent colors
        final parsedColors = colors
            .map((c) => _parseColor(c.toString()))
            .where((color) => color != null && color.opacity > 0)
            .toList();

        Color? effectiveColor;

        if (parsedColors.isNotEmpty) {
          // Option 1: Use the first non-transparent color (or any heuristic for dominant color)
          effectiveColor = parsedColors.first;
          // Option 2 (Alternative): Calculate an average color if multiple colors are available
          effectiveColor = _averageColor(parsedColors);
        }

        // If no valid color was detected, apply a fallback based on dark mode preference
        effectiveColor ??= prefersDarkMode ? Colors.black87 : Colors.white70;
        // Apply the effective color to the status bar
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: effectiveColor,
            statusBarIconBrightness:
                prefersDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor:
                prefersDarkMode ? Colors.black : Colors.white,
            systemNavigationBarIconBrightness:
                prefersDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        _statusBarBgColorDefault.value = effectiveColor;
        _isDarkMode.value = prefersDarkMode;
      }
    } catch (e) {}
  }

  // Function to calculate the average color of a list of Colors
  Color _averageColor(List<Color?> colors) {
    var red = 0;
    var green = 0;
    var blue = 0;

    for (final color in colors) {
      red += color!.red;
      green += color.green;
      blue += color.blue;
    }

    final colorCount = colors.length;
    return Color.fromARGB(
      255,
      red ~/ colorCount,
      green ~/ colorCount,
      blue ~/ colorCount,
    );
  }

  Color? _parseColor(String colorValue) {
    final match = RegExp(r'rgb(a?)\((\d+), (\d+), (\d+)(?:, ([\d.]+))?\)')
        .firstMatch(colorValue);

    if (match != null) {
      final r = int.parse(match.group(2)!);
      final g = int.parse(match.group(3)!);
      final b = int.parse(match.group(4)!);
      final opacity =
          match.group(5) != null ? double.parse(match.group(5)!) : 1.0;

      return Color.fromRGBO(r, g, b, opacity);
    }
    return null;
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaq = MediaQuery.of(context);
    final statusBarHeight = mediaq.padding.top;
    final scrnsize = mediaq.size;

    return ValueListenableBuilder(
      valueListenable: _isDarkMode,
      builder: (context, isDarkMode, _) {
        return ValueListenableBuilder(
          valueListenable: _canWebviewGoBack,
          builder: (context, canWebviewGoBack, _) {
            return WillPopScope(
              onWillPop: () async {
                if (canWebviewGoBack) {
                  await webViewController?.goBack();
                  return false;
                }
                return true;
              },
              child: Scaffold(
                body: Stack(
                  children: [
                    Column(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _statusBarBgColorDefault,
                          builder: (ctx, statusBarBgColorDefault, _) {
                            return Container(
                              height: statusBarHeight,
                              width: scrnsize.width,
                              color: statusBarBgColorDefault ??
                                  ColourPallette.white,
                            );
                          },
                        ),
                        Expanded(
                          child: BlocBuilder<WebviewsCubit, WebViewState>(
                            builder: (context, state) {
                              final globalUser = context
                                  .read<GlobalUserCubit>()
                                  .getGlobalUser()!;
                              final webviewcubit =
                                  context.read<WebviewsCubit>();

                              final webviewPoolItem = webviewcubit
                                  .getWebViewPoolItem(globalUser.id);

                              return InAppWebView(
                                key: webViewKey,
                                keepAlive: webviewPoolItem?.keepAliveObject,
                                initialSettings: settings,
                                pullToRefreshController:
                                    pullToRefreshController,
                                onWebViewCreated: (controller) async {
                                  webViewController = controller;
                                  // final stopWatch3 = Stopwatch()..start();
                                  await webViewController?.loadUrl(
                                    urlRequest: URLRequest(
                                      url: WebUri(widget.url),
                                    ),
                                  );
                                  // Logger.printLog(
                                  //   '[LOADURL] : ${stopWatch3.elapsedMilliseconds}',
                                  // );
                                },
                                onScrollChanged: (controller, x, y) async {
                                  if (y == 0) {
                                    // _updateStatusBarColorFromTop();
                                  }
                                  if (y > statusBarHeight) {
                                    _showAppBar.value = false;
                                    // _updateSystemTheme();
                                  } else if (y < statusBarHeight &&
                                      !_showAppBar.value) {
                                    _showAppBar.value = true;
                                  }
                                  // _previousScrollOffset = y;
                                },
                                onLoadStart: (controller, url) async {
                                  await _updateCanBack();
                                },
                                onGeolocationPermissionsShowPrompt:
                                    (controller, origin) async {
                                  // Request location permission
                                  // Logger.printLog('[PERMISSION] : ${origin} REQUESTED');

                                  final locationGranted =
                                      await _requestPermission(
                                    Permission.location,
                                  );

                                  return GeolocationPermissionShowPromptResponse(
                                    origin: origin,
                                    allow: locationGranted,
                                    retain: true,
                                  );
                                },
                                onPermissionRequest:
                                    (controller, request) async {
                                  var granted = false;

                                  if (request.resources.contains(
                                    PermissionResourceType.GEOLOCATION,
                                  )) {
                                    granted = await _requestPermission(
                                      Permission.location,
                                    );
                                  }
                                  if (request.resources.contains(
                                      PermissionResourceType.CAMERA)) {
                                    granted = await _requestPermission(
                                      Permission.camera,
                                    );
                                  }
                                  if (request.resources.contains(
                                    PermissionResourceType.MICROPHONE,
                                  )) {
                                    granted = await _requestPermission(
                                      Permission.microphone,
                                    );
                                  }
                                  if (request.resources.contains(
                                    PermissionResourceType.PROTECTED_MEDIA_ID,
                                  )) {
                                    granted = await _requestPermission(
                                      Permission.storage,
                                    );
                                  }

                                  return PermissionResponse(
                                    resources: request.resources,
                                    action: granted
                                        ? PermissionResponseAction.GRANT
                                        : PermissionResponseAction.DENY,
                                  );
                                },
                                shouldOverrideUrlLoading:
                                    (controller, navigationAction) async {
                                  return NavigationActionPolicy.ALLOW;
                                },
                                onLoadStop: (controller, url) async {
                                  await pullToRefreshController
                                      ?.endRefreshing()
                                      .catchError((_) {});

                                  // Store original URL on first load
                                  // _url.value ??= url?.rawValue;
                                  // Logger.printLog(
                                  //   '[LOADEDURL] : ${url?.rawValue}',
                                  // );
                                  // Clear history only if user is navigating outside original URL context
                                  if (_historyCleared == false) {
                                    // final stopWatch4 = Stopwatch()..start();
                                    await webViewController?.clearHistory();
                                    await controller
                                        .getCopyBackForwardList()
                                        .then((list) {
                                      if (list == null) return;
                                      // for (final his
                                      //     in list.list ?? <WebHistoryItem>[]) {
                                      //   Logger.printLog(
                                      //     '[webhistory] : ${his.url?.rawValue}\n',
                                      //   );
                                      // }
                                      _prevBackListUrl.value ??= list.list;
                                    });
                                    // Logger.printLog(
                                    //   '[CR]: History cleared. ${stopWatch4.elapsedMilliseconds}',
                                    // );
                                    _historyCleared = true;
                                  }

                                  await _updateCanBack();
                                  await _updateStatusBarColorFromTop();
                                },
                                onReceivedError: (controller, request, error) {
                                  pullToRefreshController
                                      ?.endRefreshing()
                                      .catchError(
                                    (_) async {
                                      final theme = Theme.of(context);
                                      await CustomTabsService.launchUrl(
                                        url: request.url.toString(),
                                        theme: theme,
                                      ).then(
                                        (_) async {
                                          // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                          // JUST LIKE APPS IN BACKGROUND TYPE
                                        },
                                      );
                                    },
                                  );
                                },
                                onProgressChanged: (controller, progress) {
                                  if (progress == 100) {
                                    pullToRefreshController
                                        ?.endRefreshing()
                                        .catchError(
                                          (_) {},
                                        );
                                  }
                                  _progress.value = progress / 100;
                                  // urlController.text = _url.value;
                                },
                                onUpdateVisitedHistory:
                                    (controller, url, androidIsReload) async {
                                  await _updateCanBack();
                                },
                                onConsoleMessage: (controller, consoleMessage) {
                                  if (kDebugMode) {
                                    print(consoleMessage);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: _progress,
                      builder: (ctx, progress, _) {
                        if (progress < 1.0) {
                          return LinearProgressIndicator(
                            value: progress,
                            minHeight: 2,
                            color: Colors.green,
                            backgroundColor: Colors.grey.withOpacity(0.75),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
