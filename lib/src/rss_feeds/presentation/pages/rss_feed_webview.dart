import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:html/dom.dart' as dom;
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/services/rss_data_parsing_service.dart';
import 'package:link_vault/core/services/url_parsing_service.dart';
import 'package:link_vault/core/utils/logger.dart';

// Use this https://github.com/xaynetwork/xayn_readabilityc
class RSSFeedWebView extends StatefulWidget {
  const RSSFeedWebView({required this.url, super.key});

  final String url;

  @override
  State<RSSFeedWebView> createState() => _RSSFeedWebViewState();
}

class _RSSFeedWebViewState extends State<RSSFeedWebView> {
  final GlobalKey webViewKey = GlobalKey();
  final _showAppBar = ValueNotifier(true);
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
    useWideViewPort: false,
  );

  PullToRefreshController? pullToRefreshController;
  final _url = ValueNotifier('');
  final _progress = ValueNotifier<double>(0);
  final urlController = TextEditingController();
  final _urlLoadState = ValueNotifier(LoadingStates.initial);

  final _isDarkMode = ValueNotifier(false);

  String? readabilityScript;

  final _extractedContent = ValueNotifier('Extracting content...');
  final _extractingContentLoadState = ValueNotifier(LoadingStates.initial);
  InAppWebViewController? webViewControllerExtracted;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        // systemNavigationBarColor:
        //     _isDarkMode.value ? Colors.black : Colors.white,
        // systemNavigationBarIconBrightness:
        //     _isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    );
    // _loadReadabilityScript();
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
                      URLRequest(url: await webViewController?.getUrl()),
                );
              }
            },
          );
  }

  // Future<void> _loadReadabilityScript() async {
  // Load the Readability.js file from assets
  //   readabilityScript = await rootBundle
  //       .loadString('assets/js/readability/readabilityjs/Readability.js');
  // }

  Future<void> _updateCanBack() async {
    if (webViewController != null) {
      final webviewCanGoBack = await webViewController!.canGoBack();
      _canWebviewGoBack.value = webviewCanGoBack;
      // Logger.printLog('CanGoBack updated: $canWebviewGoBack');
    }
  }

  Future<void> _detectDarkMode() async {
    // JavaScript to detect background color
    final bgColor = webViewController
        ?.evaluateJavascript(
          source:
              'window.getComputedStyle(document.body, null).backgroundColor',
        )
        .toString();

    if (bgColor != null) {
      // Here, we are assuming dark mode if background is dark (you might refine this with specific colors)
      final isDark =
          bgColor.contains('rgb(0, 0, 0)') || bgColor.contains('rgba(0, 0, 0');

      if (isDark != _isDarkMode.value) {
        // setState(() {
        _isDarkMode.value = isDark;
        _updateSystemTheme();
        // });
      }
    }
  }

  void _updateSystemTheme() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: _isDarkMode.value ? Colors.black : Colors.white,
        statusBarIconBrightness:
            _isDarkMode.value ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            _isDarkMode.value ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            _isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
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
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
      valueListenable: _isDarkMode,
      builder: (context, isDarkMode, _) {
        return ValueListenableBuilder(
          valueListenable: _canWebviewGoBack,
          builder: (context, canWebviewGoBack, _) {
            return PopScope(
              canPop: !canWebviewGoBack,
              onPopInvokedWithResult: (pop, _) async {
                // Logger.printLog('CanGoBack popsc: $canWebviewGoBack');
                if (canWebviewGoBack) {
                  // Logger.printLog(
                  //     '${await webViewController?.canGoBack()} WebView can go back, navigating back');

                  await webViewController?.goBack();
                } else {
                  // Logger.printLog('CanGoBack WebView cannot go back, popping screen');
                  // await Navigator.of(context).maybePop();
                }
              },
              child: Scaffold(
                // appBar: _getAppBar(),
                body: SafeArea(
                  child: Stack(
                    children: [
                      SizedBox(
                        width: size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _urlLoadState,
                              builder: (context, urlLoadState, _) {
                                if (urlLoadState == LoadingStates.loaded) {
                                  return const SizedBox.shrink();
                                }
                                return SizedBox(
                                  height: 0.0,
                                  child: InAppWebView(
                                    key: webViewKey,
                                    initialUrlRequest:
                                        URLRequest(url: WebUri(widget.url)),
                                    initialSettings: settings,
                                    pullToRefreshController:
                                        pullToRefreshController,
                                    onWebViewCreated: (controller) {
                                      webViewController = controller;
                                    },
                                    onScrollChanged: (controller, x, y) {
                                      // Hide/show AppBar based on scroll direction
                                      // Logger.printLog('CanGoBack Scroll: $x, $y');
                                      if (y > _previousScrollOffset) {
                                        _showAppBar.value = false;
                                      } else if (y < _previousScrollOffset) {
                                        _showAppBar.value = true;
                                      }
                                      _previousScrollOffset = y;
                                    },
                                    onLoadStart: (controller, url) {
                                      _url.value = url.toString();
                                      urlController.text = _url.value;
                                      _urlLoadState.value =
                                          LoadingStates.loading;
                                    },
                                    onPermissionRequest:
                                        (controller, request) async {
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
                                      try {
                                        await extractMainContent(widget.url);

                                        _url.value = url.toString();
                                        urlController.text = _url.value;

                                        await Future.wait(
                                          [
                                            Future(
                                              () async =>
                                                  await pullToRefreshController
                                                      ?.endRefreshing(),
                                            ),
                                            _detectDarkMode(),
                                            _updateCanBack(),
                                          ],
                                        );
                                        _urlLoadState.value =
                                            LoadingStates.loaded;
                                      } catch (e) {
                                        // Logger.printLog('RSS Feed WebView error $e');
                                      }
                                    },
                                    onReceivedError:
                                        (controller, request, error) {
                                      pullToRefreshController?.endRefreshing();
                                    },
                                    onProgressChanged: (controller, progress) {
                                      if (progress == 100) {
                                        pullToRefreshController
                                            ?.endRefreshing();
                                      }
                                      _progress.value = progress / 100;
                                      urlController.text = _url.value;
                                    },
                                    onUpdateVisitedHistory: (controller, url,
                                        androidIsReload) async {
                                      _url.value = url.toString();
                                      urlController.text = _url.value;
                                      await _updateCanBack(); // Update canGoBack on history update
                                    },
                                    onConsoleMessage:
                                        (controller, consoleMessage) {
                                      if (kDebugMode) {
                                        print(consoleMessage);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _extractingContentLoadState,
                              builder: (context, loadingState, _) {
                                if (loadingState == LoadingStates.loading) {
                                  return Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: ColourPallette.salemgreen,
                                            backgroundColor: ColourPallette
                                                .mystic
                                                .withOpacity(0.75),
                                          ),
                                          const SizedBox(height: 12),
                                          const Center(
                                            child: Text('Loading Content...'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (loadingState ==
                                    LoadingStates.errorLoading) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: SvgPicture.asset(
                                            MediaRes.errorANIMATION,
                                          ),
                                        ),
                                        const Center(
                                          child: Text('Loading Content...'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _extractingContentLoadState,
                              builder:
                                  (context, extractingContentLoadState, _) {
                                if (extractingContentLoadState !=
                                    LoadingStates.loaded) {
                                  return const SizedBox.shrink();
                                }

                                return Expanded(
                                  child: Container(
                                    width: size.width,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                    child: InAppWebView(
                                      initialSettings: InAppWebViewSettings(
                                        useOnLoadResource: true,
                                        isInspectable: kDebugMode,
                                        mediaPlaybackRequiresUserGesture: false,
                                        allowsInlineMediaPlayback: true,
                                        iframeAllow: 'camera; microphone',
                                        iframeAllowFullscreen: true,
                                        useWideViewPort: false,
                                      ),
                                      onWebViewCreated: (controller) async {
                                        webViewControllerExtracted = controller;

                                        final content = '''
                                        <!DOCTYPE html>
                                          <html>
                                            <head>
                                              <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
                                              <style>
                                                /* Hide scrollbars */
                                                body {
                                                  margin: 0;
                                                  padding: 0;
                                                  overflow-x: hidden; /* Prevent horizontal scrolling */
                                                }
                                                ::-webkit-scrollbar {
                                                  display: none;
                                                }

                                                /* Ensure tables and other large content fit within the viewport */
                                                table, img {
                                                  max-width: 100%;
                                                  height: auto;
                                                }

                                                /* Make sure the overall layout adjusts to smaller screens */
                                                * {
                                                  box-sizing: border-box;
                                                  word-wrap: break-word;
                                                }

                                                div {
                                                  max-width: 100%;
                                                  overflow: hidden;
                                                    }
                                                  </style>
                                                </head>
                                                <body>
                                                  ${_extractedContent.value}
                                                </body>
                                            </html>
                                        ''';

                                        await webViewControllerExtracted
                                            ?.loadData(
                                          data: content,
                                        );
                                      },
                                      onLoadStop: (controller, url) async {},
                                      onReceivedError:
                                          (controller, request, error) {
                                        pullToRefreshController
                                            ?.endRefreshing();
                                      },
                                      onConsoleMessage:
                                          (controller, consoleMessage) {
                                        if (kDebugMode) {
                                          print(consoleMessage);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
              ),
            );
          },
        );
      },
    );
  }

  Future<String> extractMainContent(String url) async {
    _extractingContentLoadState.value = LoadingStates.loading;
    try {
      // Extract the entire HTML content of the webpage
      final currentwebpage = await webViewController?.evaluateJavascript(
        source: 'document.documentElement.outerHTML;',
      );

      // Logger.printLog(currentwebpage.toString());

      // Parse the HTML document
      final document = html_parser.parse(currentwebpage);
      final body = document.body;

      if (body == null) {
        return '<p>Content not available</p>';
      }

      void cleanBody(dom.Element body) {
        const unnecessaryTags = [
          'nav',
          'footer',
          'aside',
          'header',
          'button',
          'script',
          'style',
          'form',
          'input',
          'noscript',
          'iframe',
          // 'advertisement',
          'header',
          'sidebar',
          'navigation',
          'nav',
          'menu',
          'comment',
          'related',
          'recommended',
          'share',
          'social',
          'widget',
          'promotional',
          // 'advertisement',
          // 'ad-',
          'popup',
          'modal',
        ];
        for (final tag in unnecessaryTags) {
          body.getElementsByTagName(tag).forEach((element) => element.remove());
        }

        // Remove empty or invisible elements
        body.querySelectorAll('*').forEach((element) {
          final isEmpty = element.text.trim().isEmpty;
          final isHidden =
              element.attributes['style']?.contains('display:none') ?? false;

          if (isEmpty || isHidden) {
            element.remove();
          }
        });

        // Remove elements with common ad-related classes
        // body
        //     .querySelectorAll('[class*="ad"], [id*="ad"], [class*="promo"]')
        //     .forEach((element) {
        //   element.remove();
        // });
      }

      dom.Element findMainContent(dom.Element body) {
        final selectors = [
          // Primary semantic HTML5 elements
          'main',
          'article',

          // ARIA roles
          'div[role="main"]',
          'div[role="article"]',
          'main[role="main"]',

          // Story/Article specific patterns
          'div[class*="storyline"]',
          'div[class*="story-content"]',
          'div[class*="story-body"]',
          'div[class*="article-body"]',
          'div[class*="article-content"]',
          'div[class*="article-text"]',
          'div[class*="article__content"]',
          'div[class*="article__body"]',

          // Blog/Post patterns
          'div[class*="post-content"]',
          'div[class*="post-body"]',
          'div[class*="post-text"]',
          'div[class*="post__content"]',
          'div[class*="blog-post"]',
          'div[class*="blog-content"]',
          'div[class*="entry-content"]',

          // News specific patterns
          'div[class*="news-content"]',
          'div[class*="news-article"]',
          'div[class*="news-text"]',
          'div[class*="news__content"]',

          // Main content patterns
          'div[class*="main-content"]',
          'div[class*="main-article"]',
          'div[class*="page-content"]',
          'div[class*="content-main"]',
          'div[class*="content-body"]',
          'div[class*="content-text"]',
          'div[class*="content__main"]',

          // Single content containers
          'div[class*="single-content"]',
          'div[class*="single-post"]',
          'div[class*="single-article"]',

          // Publisher specific patterns
          'div[class*="rich-text"]',
          'div[class*="markdown-body"]',
          'div[class*="container-content"]',

          // Generic content (lower priority)
          'div[class*="content"]',

          // Section based selectors (with qualifiers)
          'section[class*="content"]',
          'section[class*="article"]',
          'section[class*="post"]',
          'section[class*="story"]',
          'section:not([class*="header"]):not([class*="footer"]):not([class*="sidebar"])',
        ];

        for (final selector in selectors) {
          final content = body.querySelector(selector);
          if (content != null) {
            Logger.printLog('[SL] : $selector found $content');
            return content;
          }
        }
        return body; // Default fallback to the entire body
      }

      // String trimContent(dom.Element mainContent, {int maxLength = 5000}) {
      //   final content = mainContent.outerHtml;
      //   return content.length > maxLength
      //       ? '${content.substring(0, maxLength)}...<p>Content trimmed for brevity</p>'
      //       : content;
      // }

      void normalizeLinks(dom.Element body, Uri baseUri) {
        body.querySelectorAll('a[href]').forEach((link) {
          final href = link.attributes['href'];

          if (href != null) {
            try {
              final resolvedUrl = baseUri.resolve(href).toString();
              if (Uri.tryParse(resolvedUrl) != null) {
                link.attributes['href'] = resolvedUrl;
              } else {
                link.remove();
              }
            } catch (e) {
              link.remove(); // Remove invalid links
            }
          }
        });
      }

      void enhanceParagraph(dom.Element body) {
        // Define tags to enhance
        const contentTags = [
          'p',
          'div',
          'span',
          'article',
          'section',
          'blockquote',
          'li',
          'h3',
          'h4',
          'h5',
          'h6',
        ];
        const headerTags = ['h1', 'h2'];

        // Helper function to add/update a specific CSS property
        String addOrUpdateCss(
          String currentStyle,
          String cssAttribute,
          String value,
        ) {
          final regex = RegExp('$cssAttribute:[^;]+;');
          if (regex.hasMatch(currentStyle)) {
            return currentStyle.replaceAll(regex, '$cssAttribute: $value;');
          } else {
            return '$currentStyle$cssAttribute: $value;';
          }
        }

        // Apply styles for generic content tags
        for (final tag in contentTags) {
          final elements = body.getElementsByTagName(tag);
          for (final element in elements) {
            if (element.text.trim().isNotEmpty) {
              var existingStyle = element.attributes['style'] ?? '';

              // Add common styles only if not already present
              existingStyle =
                  addOrUpdateCss(existingStyle, 'margin-bottom', '16px');
              existingStyle =
                  addOrUpdateCss(existingStyle, 'font-size', '18px');
              existingStyle =
                  addOrUpdateCss(existingStyle, 'line-height', '1.6');
              existingStyle = addOrUpdateCss(existingStyle, 'color', '#111');

              element.attributes['style'] = existingStyle;
            }
          }
        }

        // Apply specific styles for headers (h1 and h2)
        for (final tag in headerTags) {
          final elements = body.getElementsByTagName(tag);
          for (final element in elements) {
            if (element.text.trim().isNotEmpty) {
              var existingStyle = element.attributes['style'] ?? '';

              // Apply different styles based on header type
              if (tag == 'h1') {
                existingStyle =
                    addOrUpdateCss(existingStyle, 'font-size', '24px');
                existingStyle =
                    addOrUpdateCss(existingStyle, 'margin-bottom', '16px');
                existingStyle = addOrUpdateCss(existingStyle, 'color', '#111');
              } else if (tag == 'h2') {
                existingStyle =
                    addOrUpdateCss(existingStyle, 'font-size', '20px');
                existingStyle =
                    addOrUpdateCss(existingStyle, 'margin-bottom', '12px');
                existingStyle = addOrUpdateCss(existingStyle, 'color', '#222');
              }

              element.attributes['style'] = existingStyle;
            }
          }
        }
      }

      const Color(0xFF333333);
      const Color(0xFF111111);
      const Color(0xFF222222);

      cleanBody(body);
      final mainContent = findMainContent(body);
      normalizeLinks(mainContent, Uri.parse(url));
      enhanceParagraph(mainContent);

      // Optional: Trim long content
      // final trimmedContent = (mainContent);
      // ADD HIDE SCROLLBARS
      // Return the sanitized HTML as a string
      _extractedContent.value = mainContent.outerHtml;
      _extractingContentLoadState.value = LoadingStates.loaded;
      // await webViewController?.loadData(data: _extractedContent.value);
      Logger.printLog(_extractedContent.value);

      return mainContent.outerHtml;
    } catch (error) {
      if (kDebugMode) {
        print('Error extracting content: $error');
      }
      _extractingContentLoadState.value = LoadingStates.errorLoading;

      return '<p>Error extracting content</p>';
    }
  }
}
