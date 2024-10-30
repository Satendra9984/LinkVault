import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:url_launcher/url_launcher.dart';

// WebViewEnvironment? webViewEnvironment;

class DashboardWebView extends StatefulWidget {
  const DashboardWebView({required this.url, super.key});

  final String url;

  @override
  State<DashboardWebView> createState() => _DashboardWebViewState();
}

class _DashboardWebViewState extends State<DashboardWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    cacheEnabled: true,
    useOnLoadResource: true, // Ensures it caches resources when loading.
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;
  final _url = ValueNotifier('');
  final _progress = ValueNotifier<double>(0.0);
  final urlController = TextEditingController();

  @override
  void initState() {
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
              if (defaultTargetPlatform == TargetPlatform.android) {
                await webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                await webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (pop, _) {},
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onLongPress: () {
              // TODO : SHOW APP BAR

              // TODO : SHOW BOTTOM BAR
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                        initialSettings: settings,
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          _url.value = url.toString();
                          urlController.text = _url.value;
                        },
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.PROMPT,
                          );
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          await pullToRefreshController?.endRefreshing();

                          _url.value = url.toString();
                          urlController.text = _url.value;
                        },
                        onReceivedError: (controller, request, error) {
                          pullToRefreshController?.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController?.endRefreshing();
                          }
                          _progress.value = progress / 100;
                          urlController.text = _url.value;
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {
                          _url.value = url.toString();
                          urlController.text = _url.value;
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          if (kDebugMode) {
                            print(consoleMessage);
                          }
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _progress,
                        builder: (ctx, progress, _) {
                          if (progress < 1.0) {
                            return LinearProgressIndicator(
                              value: progress,
                              minHeight: 2,
                              color: ColourPallette.salemgreen,
                              backgroundColor:
                                  ColourPallette.mystic.withOpacity(0.75),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TODO : USE THIS CODE FOR BACKBUTTONS CONTROL
/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class NavigationWebView extends StatefulWidget {
  final String initialUrl;
  final VoidCallback? onClose;

  const NavigationWebView({
    Key? key,
    required this.initialUrl,
    this.onClose,
  }) : super(key: key);

  @override
  State<NavigationWebView> createState() => _NavigationWebViewState();
}

class _NavigationWebViewState extends State<NavigationWebView> {
  late WebViewController _controller;
  Timer? _backButtonTimer;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          _updateCanGoBack();
        },
        onNavigationRequest: (NavigationRequest request) {
          // Optional: Handle navigation requests
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _updateCanGoBack() async {
    if (!mounted) return;
    final canGoBack = await _controller.canGoBack();
    setState(() {
      _canGoBack = canGoBack;
    });
  }

  Future<bool> _handleBackPress() async {
    if (_backButtonTimer?.isActive ?? false) {
      // Long press detected
      _backButtonTimer?.cancel();
      widget.onClose?.call();
      return true;
    }

    if (await _controller.canGoBack()) {
      _backButtonTimer = Timer(const Duration(milliseconds: 500), () {
        // Single press - go back in WebView
        _controller.goBack();
      });
      return false;
    } else {
      // No more history, handle close
      widget.onClose?.call();
      return true;
    }
  }

  @override
  void dispose() {
    _backButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
        // Optional: Add navigation controls
        bottomNavigationBar: NavigationControls(
          controller: _controller,
          onClose: widget.onClose,
        ),
      ),
    );
  }
}

// Optional: Navigation Controls Widget
class NavigationControls extends StatelessWidget {
  final WebViewController controller;
  final VoidCallback? onClose;

  const NavigationControls({
    Key? key,
    required this.controller,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await controller.canGoBack()) {
                controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await controller.canGoForward()) {
                controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
*/

