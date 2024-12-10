import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
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
  int _previousScrollOffset = 0;
  InAppWebViewController? webViewController;
  final _canWebviewGoBack = ValueNotifier(false);

  InAppWebViewSettings settings = InAppWebViewSettings(
    useOnLoadResource: true,
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;
  final _url = ValueNotifier('');
  final _progress = ValueNotifier<double>(0);
  final urlController = TextEditingController();
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

    SystemChrome.setSystemUIChangeCallback(
      (change) async {
        if (userSwipedSystemStatusBar.value < 1) {
          userSwipedSystemStatusBar.value++;
          return;
        }
        // Logger.printLog('[setuicalled]');
        // await SystemChrome.setEnabledSystemUIMode(
        //   SystemUiMode.manual,
        //   overlays: [
        //     SystemUiOverlay.top,
        //     SystemUiOverlay.bottom,
        //   ],
        // );
        return;
      },
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
    if (webViewController != null) {
      final webviewCanGoBack = await webViewController!.canGoBack();
      _canWebviewGoBack.value = webviewCanGoBack;
    }
  }

  Future<void> _updateStatusBarColorFromTop() async {
    // Logger.printLog('[WEBVIEW] : _updateStatusBarColorFromTop');

    // if (_statusBarBgColorDefault.value != null) {
    //   SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle(
    //       statusBarColor: _statusBarBgColorDefault.value,
    //       statusBarIconBrightness:
    //           _isDarkMode.value ? Brightness.light : Brightness.dark,
    //       systemNavigationBarColor:
    //           _isDarkMode.value ? Colors.black : Colors.white,
    //       systemNavigationBarIconBrightness:
    //           _isDarkMode.value ? Brightness.light : Brightness.dark,
    //     ),
    //   );
    //   return;
    // }

    // final bgColor = await webViewController?.evaluateJavascript(
    //   source: 'window.getComputedStyle(document.header, null).backgroundColor',
    // );

    // Logger.printLog('[bgcol] : ${bgColor}');
    // Color.fromARGB(255, 227, 230, 230);

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
      final result = jsonDecode(colorValue.toString()) as Map<String, dynamic>;
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
        // Logger.printLog(
        //   'statusbarcolor: $parsedColors $effectiveColor, mode: $prefersDarkMode',
        // );
      }

      // If no valid color was detected, apply a fallback based on dark mode preference
      effectiveColor ??= prefersDarkMode ? Colors.black87 : Colors.white70;
      // Logger.printLog(
      //   'statusbarcoloe: $parsedColors, mode: $prefersDarkMode',
      // );
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

      // Logger.printLog(
      //   '[WEBVIEW] : final effective color: $effectiveColor, darkMode: $prefersDarkMode',
      // );
    }
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
        255, red ~/ colorCount, green ~/ colorCount, blue ~/ colorCount,);
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

  void _updateSystemTheme() {
    // Logger.printLog('[WEBVIEW] : themeMode: $_isDarkMode');
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
            _isDarkMode.value ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            _isDarkMode.value ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            _isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    );
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
                // backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onVerticalDragStart: (details) {
                            if (details.globalPosition.dy >
                                MediaQuery.of(context).size.height * 0.9) {
                              // Detect swipe near the bottom of the screen
                              userSwipedSystemStatusBar.value = 1;
                            }
                          },
                          child: ValueListenableBuilder(
                            valueListenable: _showAppBar,
                            builder: (ctx, showAppBar, _) {
                              // if (!showAppBar) {
                              //   return SizedBox(height: statusBarHeight);
                              // }
                              return ValueListenableBuilder(
                                valueListenable: _statusBarBgColorDefault,
                                builder: (ctx, statusBarBgColorDefault, _) {
                                  return Container(
                                    height: statusBarHeight,
                                    width: scrnsize.width,
                                    color: statusBarBgColorDefault ??
                                        ColourPallette.white,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: InAppWebView(
                            key: webViewKey,
                            initialUrlRequest:
                                URLRequest(url: WebUri(widget.url)),

                            // keepAlive: ,

                            initialSettings: settings,
                            pullToRefreshController: pullToRefreshController,
                            onWebViewCreated: (controller) {
                              webViewController = controller;
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
                              _previousScrollOffset = y;
                              //  SystemChrome.setEnabledSystemUIMode(
                              //   SystemUiMode.manual,
                              //   overlays: [
                              //     SystemUiOverlay.top,
                              //   ],
                              // );
                            },
                            onLoadStart: (controller, url) {
                              _url.value = url.toString();
                              urlController.text = _url.value;
                            },
                            onGeolocationPermissionsShowPrompt:
                                (controller, origin) async {
                              // Request location permission
                              // Logger.printLog('[PERMISSION] : ${origin} REQUESTED');

                              final locationGranted = await _requestPermission(
                                Permission.location,
                              );

                              return GeolocationPermissionShowPromptResponse(
                                origin: origin,
                                allow: locationGranted,
                                retain: true,
                              );
                            },
                            onPermissionRequest: (controller, request) async {
                              var granted = false;

                              if (request.resources.contains(
                                  PermissionResourceType.GEOLOCATION,)) {
                                granted = await _requestPermission(
                                  Permission.location,
                                );
                              }
                              if (request.resources
                                  .contains(PermissionResourceType.CAMERA)) {
                                granted = await _requestPermission(
                                  Permission.camera,
                                );
                              }
                              if (request.resources.contains(
                                  PermissionResourceType.MICROPHONE,)) {
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
                                  .catchError(
                                    (_) {},
                                  );
                              _url.value = url.toString();
                              urlController.text = _url.value;
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
                              urlController.text = _url.value;
                            },
                            onUpdateVisitedHistory:
                                (controller, url, androidIsReload) async {
                              _url.value = url.toString();
                              urlController.text = _url.value;
                              await _updateCanBack();
                            },
                            onConsoleMessage: (controller, consoleMessage) {
                              if (kDebugMode) {
                                print(consoleMessage);
                              }
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
