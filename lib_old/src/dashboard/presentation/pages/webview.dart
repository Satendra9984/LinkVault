import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:link_vault/src/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/webview_cubit/webviews_cubit.dart';
import 'package:link_vault/src/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:path/path.dart';
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
  final _bottomBarBgColorDefault = ValueNotifier<Color?>(null);

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
  final _prevBackListUrl = ValueNotifier(<WebHistoryItem>[]);
  final _progress = ValueNotifier<double>(0);
  final _isDarkMode = ValueNotifier(false);
  final _isAppBarVisible = ValueNotifier(true);
  final _currentUrl = ValueNotifier('');
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
    _currentUrl.value = widget.url;

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
      _canWebviewGoBack.value = await webViewController?.canGoBack() ?? false;
    } catch (e) {
      Logger.printLog('Error in _updateCanBack: $e');
    }
  }

  Future<void> _handleDoubleTap(InAppWebViewController controller) async {
    try {
      await controller.addUserScript(
        userScript: UserScript(
          source: """
          let lastTapTime = 0;
          document.addEventListener('touchend', function(e) {
            const currentTime = new Date().getTime();
            const timeDifference = currentTime - lastTapTime;
            if (timeDifference < 300) {
              window.flutter_inappwebview.callHandler('onDoubleTap');
            }
            lastTapTime = currentTime;
          });
        """,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      );

      controller.addJavaScriptHandler(
        handlerName: 'onDoubleTap',
        callback: (args) {
          Logger.printLog(
              'Double tap detected. IsAppBarVisible: ${_isAppBarVisible.value}');
          _isAppBarVisible.value = !_isAppBarVisible.value;
        },
      );
    } catch (e) {
      Logger.printLog('Error in _handleDoubleTap: $e');
    }
  }

  Future<void> _updateStatusBarColor() async {
    try {
      await _updateBottomBarColorFromBody(); // body color
    } catch (e) {
      Logger.printLog('Failed to update status bar color: $e');
    }
  }

// Helper function to parse CSS color
  Color _parseCssColor(String cssColor) {
    final match = RegExp(r'rgba?\((\d+), (\d+), (\d+)').firstMatch(cssColor);
    if (match != null) {
      return Color.fromRGBO(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        1.0,
      );
    }
    return Colors.grey;
  }

  Color _mapToWhiteOrBlack(Color color) {
    final brightness =
        (0.299 * color.red) + (0.587 * color.green) + (0.114 * color.blue);
    return brightness > 128 ? Colors.white : Colors.black;
  }

  Future<void> _updateBottomBarColorFromBody() async {
    try {
      final result = await webViewController?.evaluateJavascript(
        source: '''
        (() => {
          const getColor = (element) => {
            const style = window.getComputedStyle(element);
            return style.backgroundColor !== 'transparent' && style.backgroundColor !== ''
              ? style.backgroundColor
              : null;
          };

          let bgColor = getColor(document.body) || getColor(document.documentElement);
          
          // Fallback to white if no valid background color is detected
          return bgColor || 'rgb(255, 255, 255)';
        })();
      ''',
      );

      if (result != null) {
        final extractedColor = _parseCssColor(result.toString());
        final mappedColor = _mapToWhiteOrBlack(extractedColor);

        _bottomBarBgColorDefault.value = mappedColor;
        _statusBarBgColorDefault.value = mappedColor;

        Logger.printLog('Mapped BottomBarColor: $mappedColor');
      }
    } catch (e) {
      Logger.printLog('Failed to extract body background color: $e');
      _bottomBarBgColorDefault.value = Colors.white; // Fallback to white
      _statusBarBgColorDefault.value = Colors.white;
    }
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
                try {
                  final canGoBack = canWebviewGoBack;
                  // await webViewController?.canGoBack();

                  if (canGoBack != null && canGoBack) {
                    await webViewController?.goBack();
                    return false;
                  } else {
                    return true;
                  }
                } catch (e) {
                  return true;
                }
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
                                  try {
                                    // Ensure double-tap script is added before loading URL
                                    await _handleDoubleTap(controller);
                                    // Load the actual URL
                                    await webViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                        url: WebUri(widget.url),
                                      ),
                                    );
                                  } catch (e) {
                                    Logger.printLog(
                                      'Error during WebView initialization: $e',
                                    );
                                  }
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
                                  // Logger.printLog(
                                  //   'onLoadStart: ${url?.rawValue}',
                                  // );
                                  // await _updateCanBack();
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
                                  // Logger.printLog(
                                  //   'onLoadStop: ${url?.rawValue}',
                                  // );
                                  // await _updateCanBack();
                                  await _updateStatusBarColor();
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
                                        .catchError((_) {});
                                  }
                                  _progress.value = progress / 100;
                                },
                                onUpdateVisitedHistory:
                                    (controller, url, androidIsReload) async {
                                  _currentUrl.value =
                                      url?.rawValue ?? _currentUrl.value;
                                  // Logger.printLog(
                                  //   'onUpdateVisitedHistory : ${url?.rawValue}, '
                                  //   '${_currentUrl.value}',
                                  // );
                                  await Future.wait(
                                    [
                                      _updateCanBack(),
                                      Future(
                                        () async {
                                          if (_historyCleared == false) {
                                            await webViewController
                                                ?.clearHistory();
                                            await controller
                                                .getCopyBackForwardList()
                                                .then(
                                              (backlist) {
                                                if (backlist == null ||
                                                    backlist.list == null) {
                                                  return;
                                                }
                                                // for (final his in backlist.list!) {
                                                //   Logger.printLog(
                                                //       '${his.url?.rawValue}');
                                                // }
                                                _prevBackListUrl.value =
                                                    backlist.list!;
                                              },
                                            );
                                            _historyCleared = true;
                                            // Logger.printLog('CLEARED HISTORY');
                                          }
                                        },
                                      ),
                                      _updateStatusBarColor(),
                                    ],
                                  );
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
                        ValueListenableBuilder(
                          valueListenable: _isAppBarVisible,
                          builder: (context, isAppbarVisible, _) {
                            if (isAppbarVisible == false) {
                              return const SizedBox.shrink();
                            }

                            return ValueListenableBuilder(
                              valueListenable: _bottomBarBgColorDefault,
                              builder: (context, bottomBarColor, _) {
                                final backgroundColor =
                                    bottomBarColor ?? Colors.white;

                                // Calculate luminance
                                final luminance = (0.299 * backgroundColor.red +
                                        0.587 * backgroundColor.green +
                                        0.114 * backgroundColor.blue) /
                                    255;

                                // Determine contrasting content color
                                final contentColor = luminance > 0.5
                                    ? Colors.black
                                    : Colors.white;

                                // Logger.printLog(
                                //   'colors: $backgroundColor, cc: $contentColor',
                                // );

                                return Container(
                                  // height: 56,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (e) {}
                                        },
                                        color: contentColor,
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: contentColor.withOpacity(0.75),
                                        ),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: _canWebviewGoBack,
                                        builder:
                                            (context, canWebviewGoBack, _) {
                                          return CircleAvatar(
                                            backgroundColor:
                                                contentColor.withOpacity(0.1),
                                            child: IconButton(
                                              onPressed: () async {
                                                try {
                                                  if (canWebviewGoBack ==
                                                      false) {
                                                    Navigator.pop(context);
                                                  }
                                                  await webViewController
                                                      ?.goBack();
                                                } catch (e) {
                                                  Logger.printLog(
                                                    'WebViewGoBack: error $e',
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.arrow_back_ios,
                                                color: contentColor,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      CircleAvatar(
                                        backgroundColor:
                                            contentColor.withOpacity(0.1),
                                        child: IconButton(
                                          onPressed: () async {
                                            try {
                                              await webViewController
                                                  ?.goForward();
                                            } catch (e) {}
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: contentColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color:
                                                  contentColor.withOpacity(0.1),
                                            ),
                                            child: ValueListenableBuilder(
                                              valueListenable: _currentUrl,
                                              builder:
                                                  (context, currentUrl, _) {
                                                return Text(
                                                  currentUrl,
                                                  style: TextStyle(
                                                    color: contentColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.visible,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
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
