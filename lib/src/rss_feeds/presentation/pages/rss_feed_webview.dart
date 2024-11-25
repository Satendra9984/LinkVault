import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:html/dom.dart' as dom;
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/services/file_service.dart';
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

    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.immersive,
    //   overlays: [
    //     SystemUiOverlay.top,
    //   ],
    // );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
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
            settings: PullToRefreshSettings(color: Colors.blue),
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
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.edgeToEdge,
    // );
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
                body: Stack(
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
                                    _urlLoadState.value = LoadingStates.loading;
                                    _extractingContentLoadState.value =
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
                                      pullToRefreshController?.endRefreshing();
                                    }
                                    _progress.value = progress / 100;
                                    urlController.text = _url.value;
                                  },
                                  onUpdateVisitedHistory:
                                      (controller, url, androidIsReload) async {
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
                                          backgroundColor: ColourPallette.mystic
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        // child: SvgPicture.asset(
                                        //   MediaRes.errorANIMATION,
                                        // placeholderBuilder: (context) {
                                        //   return Icon(
                                        //     Icons.error_rounded,
                                        //     color: ColourPallette.error,
                                        //   );
                                        // },
                                        child: Icon(
                                          Icons.error_rounded,
                                          color: ColourPallette.error,
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
                            builder: (context, extractingContentLoadState, _) {
                              if (extractingContentLoadState !=
                                  LoadingStates.loaded) {
                                return const SizedBox.shrink();
                              }

                              return Expanded(
                                child: SizedBox(
                                  width: size.width,
                                  // padding: const EdgeInsets.symmetric(
                                  //     horizontal: 16, vertical: 0),
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

                                      await webViewControllerExtracted
                                          ?.loadData(
                                        data: _extractedContent.value,
                                      );
                                    },
                                    onLoadStop: (controller, url) async {},
                                    onReceivedError:
                                        (controller, request, error) {
                                      // Logger.printLog(
                                      //   '[WEBVIEW] : ${error.description}',
                                      // );
                                      // pullToRefreshController
                                      //     ?.endRefreshing();
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
            );
          },
        );
      },
    );
  }

  Future<String> extractMainContent(String url) async {
    _extractingContentLoadState.value = LoadingStates.loading;
    _progress.value = 1.0;
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

      const double _minContentRatio = 0.3; // Minimum text-to-markup ratio
      const int _minTextLength = 1000; // Minimum text content length

      bool _shouldExcludeElement(dom.Element element) {
        // Exclude hidden elements
        if (element.attributes['style']?.contains('display: none') ?? false) {
          return true;
        }

        // Exclude elements with minimal content
        final text = element.text.trim();
        if (text.length < _minTextLength) {
          return true;
        }

        // Exclude common non-content areas
        final classNames = element.classes.join(' ').toLowerCase();
        return classNames.contains('comment') ||
            classNames.contains('sidebar') ||
            classNames.contains('footer') ||
            classNames.contains('header') ||
            classNames.contains('nav');
      }

      int _calculateContentScore(dom.Element element) {
        int score = 0;

        // Get text content length
        final text = element.text.trim();
        score += text.length;

        // Bonus for semantic elements and ARIA roles
        if (element.localName == 'main' || element.localName == 'article') {
          score += 300;
        }
        if (element.attributes['role'] == 'main' ||
            element.attributes['role'] == 'article') {
          score += 200;
        }

        // Bonus for content-related classes
        final classNames = element.classes.join(' ').toLowerCase();
        if (classNames.contains('content') ||
            classNames.contains('article') ||
            classNames.contains('post')) {
          score += 100;
        }

        // Penalize for deep nesting
        int depth = 0;
        dom.Node? parent = element;
        while (parent != null) {
          depth++;
          parent = parent.parent;
        }
        score -= depth * 10;

        // Check text-to-markup ratio
        final markup = element.outerHtml.length;
        if (markup > 0) {
          final ratio = text.length / markup;
          if (ratio > _minContentRatio) {
            score += (ratio * 100).round();
          }
        }

        return score;
      }

      dom.Element findMainContent(dom.Element body) {
        final selectors = [
          // Primary semantic HTML5 elements (highest priority)
          'main',
          'article',

          // ARIA roles (high priority)
          '[role="main"]',
          '[role="article"]',

          // Story/Article patterns
          'div[class*="storyline"], div[class*="story-content"], div[class*="story-body"]',
          'div[class*="article-body"], div[class*="article-content"], div[class*="article-text"]',
          'div[class*="article__content"], div[class*="article__body"]',

          // Blog/Post patterns
          'div[class*="post-content"], div[class*="post-body"], div[class*="post-text"]',
          'div[class*="post__content"], div[class*="blog-post"], div[class*="blog-content"]',
          'div[class*="entry-content"]',

          // News patterns
          'div[class*="news-content"], div[class*="news-article"], div[class*="news-text"]',
          'div[class*="news__content"]',

          // Main content patterns
          'div[class*="main-content"], div[class*="main-article"], div[class*="page-content"]',
          'div[class*="content-main"], div[class*="content-body"], div[class*="content-text"]',
          'div[class*="content__main"]',

          // Single content containers
          'div[class*="single-content"], div[class*="single-post"], div[class*="single-article"]',

          // Publisher specific patterns
          'div[class*="rich-text"], div[class*="markdown-body"], div[class*="container-content"]',

          // Generic content (lower priority)
          'div[class*="content"]',

          // Section based selectors (lowest priority)
          'section[class*="content"], section[class*="article"], section[class*="post"]',
          'section[class*="story"]',
          'section:not([class*="header"]):not([class*="footer"]):not([class*="sidebar"])',
        ];

        dom.Element? bestMatch;
        var maxScore = 0;

        for (final selector in selectors) {
          final elements = body.querySelectorAll(selector);

          for (final element in elements) {
            // if (_shouldExcludeElement(element)) continue;

            final score = _calculateContentScore(element);
            if (score > maxScore) {
              maxScore = score;
              bestMatch = element;
            }
          }

          // If we found a high-scoring match with semantic elements, stop searching
          if (maxScore > 1000 && selector.contains('main') ||
              selector.contains('article')) {
            break;
          }
        }

        return bestMatch ?? body;
      }

      // dom.Element findMainContent(dom.Element body) {
      //   final selectors = [
      //     // Primary semantic HTML5 elements
      //     'main',
      //     'article',

      //     // ARIA roles
      //     'div[role="main"]',
      //     'div[role="article"]',
      //     'main[role="main"]',

      //     // Story/Article specific patterns
      //     'div[class*="storyline"]',
      //     'div[class*="story-content"]',
      //     'div[class*="story-body"]',
      //     'div[class*="article-body"]',
      //     'div[class*="article-content"]',
      //     'div[class*="article-text"]',
      //     'div[class*="article__content"]',
      //     'div[class*="article__body"]',

      //     // Blog/Post patterns
      //     'div[class*="post-content"]',
      //     'div[class*="post-body"]',
      //     'div[class*="post-text"]',
      //     'div[class*="post__content"]',
      //     'div[class*="blog-post"]',
      //     'div[class*="blog-content"]',
      //     'div[class*="entry-content"]',

      //     // News specific patterns
      //     'div[class*="news-content"]',
      //     'div[class*="news-article"]',
      //     'div[class*="news-text"]',
      //     'div[class*="news__content"]',

      //     // Main content patterns
      //     'div[class*="main-content"]',
      //     'div[class*="main-article"]',
      //     'div[class*="page-content"]',
      //     'div[class*="content-main"]',
      //     'div[class*="content-body"]',
      //     'div[class*="content-text"]',
      //     'div[class*="content__main"]',

      //     // Single content containers
      //     'div[class*="single-content"]',
      //     'div[class*="single-post"]',
      //     'div[class*="single-article"]',

      //     // Publisher specific patterns
      //     'div[class*="rich-text"]',
      //     'div[class*="markdown-body"]',
      //     'div[class*="container-content"]',

      //     // Generic content (lower priority)
      //     'div[class*="content"]',

      //     // Section based selectors (with qualifiers)
      //     'section[class*="content"]',
      //     'section[class*="article"]',
      //     'section[class*="post"]',
      //     'section[class*="story"]',
      //     'section:not([class*="header"]):not([class*="footer"]):not([class*="sidebar"])',
      //   ];

      //   for (final selector in selectors) {
      //     final content = body.querySelector(selector);
      //     if (content != null) {
      //       Logger.printLog('[SL] : $selector found ${content.outerHtml}');
      //       // Logger.printLog('[SL] : $selector found $content');
      //       return content;
      //     }
      //   }
      //   return body; // Default fallback to the entire body
      // }

      void normalizeLinks(dom.Element body, Uri baseUri) {
        body.querySelectorAll('a[href]').forEach((link) {
          final href = link.attributes['href'];
          // Logger.printLog('[LINK] : $href');
          if (href != null) {
            try {
              final resolvedUrl = baseUri.resolve(href).toString();
              if (Uri.tryParse(resolvedUrl) != null) {
                link.attributes['href'] = resolvedUrl;
                // Logger.printLog('[LINK] : resolved $resolvedUrl');
              } else {
                // Logger.printLog('[LINK] : removing parse null');
                link.remove();
              }
            } catch (e) {
              // Logger.printLog('[LINK] : removing $e');
              link.remove(); // Remove invalid links
            }
          }
        });
      }

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
                    addOrUpdateCss(existingStyle, 'font-size', '18px');
                existingStyle =
                    addOrUpdateCss(existingStyle, 'margin-bottom', '12px');
                existingStyle = addOrUpdateCss(existingStyle, 'color', '#222');
              }

              element.attributes['style'] = existingStyle;
            }
          }
        }
      }

      void enhanceImages(dom.Element body, Uri baseUri) {
        // Select all images in the body
        body.querySelectorAll('img').forEach((image) {
          Logger.printLog('[IMG] : ${image.outerHtml}');

          // Normalize the image src attribute
          final src = image.attributes['src'];
          if (src != null) {
            try {
              final resolvedUrl = baseUri.resolve(src).toString();
              if (Uri.tryParse(resolvedUrl) != null) {
                image.attributes['src'] = resolvedUrl;
              } else {
                image.remove(); // Remove invalid image URLs
              }
            } catch (e) {
              image.remove(); // Remove if resolving fails
            }
          }

          // Add or update the CSS style for images
          var existingStyle = image.attributes['style'] ?? '';
          existingStyle = addOrUpdateCss(existingStyle, 'max-width', '100%');
          existingStyle = addOrUpdateCss(existingStyle, 'height', 'auto');
          existingStyle = addOrUpdateCss(existingStyle, 'margin', '8px 0');
          existingStyle = addOrUpdateCss(existingStyle, 'display', 'block');
          image.attributes['style'] = existingStyle;

          // Ensure alt attribute for accessibility
          if (!image.attributes.containsKey('alt')) {
            image.attributes['alt'] = 'Image';
          }
        });
      }

      String extractAndAppendStyles(String htmlContent) {
        try {
          final RegExp styleTagRegExp =
              RegExp(r'<style[^>]*>(.*?)<\/style>', dotAll: true);
          final matches = styleTagRegExp.allMatches(htmlContent);

          // Extract all CSS inside <style> tags
          final StringBuffer cssBuffer = StringBuffer();
          for (final match in matches) {
            cssBuffer
                .writeln(match.group(1)); // Group 1 contains the CSS content
          }

          return cssBuffer.toString();
        } catch (e) {
          return '';
        }
      }

      String filterConflictingCSS(
          String extractedCss, List<String> restrictedProperties) {
        final RegExp cssRuleRegExp =
            RegExp(r'([^{]+)\{([^}]+)\}', dotAll: true);
        final matches = cssRuleRegExp.allMatches(extractedCss);

        final StringBuffer filteredCssBuffer = StringBuffer();

        for (final match in matches) {
          final selector = match.group(1)?.trim();
          final propertiesBlock = match.group(2)?.trim();

          if (selector != null && propertiesBlock != null) {
            final filteredProperties =
                propertiesBlock.split(';').where((property) {
              final propertyName = property.split(':')[0].trim();
              return !restrictedProperties.contains(propertyName);
            }).join(';');

            if (filteredProperties.isNotEmpty) {
              filteredCssBuffer.writeln('$selector { $filteredProperties }');
            }
          }
        }

        return filteredCssBuffer.toString();
      }

      final extractedImageUrl = UrlParsingService.extractImageUrl(document);

      // final extractedCss = extractAndAppendStyles(document.outerHtml);
      // // // Restricted properties that are already defined in the predefined styles
      // final List<String> restrictedProperties = [
      //   'margin',
      //   'padding',
      //   'background-color',
      //   'color',
      //   'font-family',
      //   'line-height',
      //   'font-size',
      //   'overflow-x',
      // ];

      // final filteredCss = filterConflictingCSS(
      //   extractedCss,
      //   restrictedProperties,
      // );
      // Logger.printLog('[CSS] : $filteredCss');

      final mainContent = findMainContent(body);
      // Logger.printLog('[FILE] : ${mainContent.innerHtml}');

      cleanBody(mainContent);
      // Logger.printLog('[FILE] : ${mainContent.innerHtml}');
      normalizeLinks(mainContent, Uri.parse(url));
      optimizeContent(mainContent); // Add this line
      enhanceParagraph(mainContent);
      enhanceImages(mainContent, Uri.parse(url));
      // await replaceImagesWithBase64(mainContent);

      // Logger.printLog('[FILE] : ${mainContent.innerHtml}');

      _extractedContent.value = '''
        <!DOCTYPE html>
            <html>
              <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
                <style>

                  body {
                    margin: 0;
                    padding: 0;
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    overflow-x: hidden; /* Prevent horizontal scrolling */
                    background-color: #f9f9f9; /* Light background for better contrast */
                    color: #333; /* Darker text for readability */
                  }

                  /* Add img styles at the end to ensure priority */
                  img {
                    max-width: 100%;
                    height: auto;
                    display: block;
                    object-fit: cover; /* Ensures the image is cropped nicely */
                  }

                  /* Hide scrollbars */
                  ::-webkit-scrollbar {
                    display: none;
                  }

                  /* Ensure tables and images fit within the viewport */
                  table, img {
                    max-width: 100%;
                    height: auto;
                  }

                  .content-container {
                    padding: 20px; /* Add padding around the body content */
                    background-color: #ffffff; /* Background to differentiate content */
                    border-radius: 8px; /* Rounded corners for a clean look */
                    padding-bottom: 56px; /* Add spacing around the container */
                    box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1); /* Subtle shadow for depth */
                 }

                  /* Overall layout adjustments */
                  * {
                    box-sizing: border-box;
                    word-wrap: break-word;
                  }

                .banner-container {
                  width: 100%;
                  /* max-height: 300px; */
                  overflow: hidden;
                  margin-bottom: 0px;
                }

                .banner-image {
                  width: 100%;
                  height: auto;
                  display: block;
                  object-fit: contain; /* Ensures the image is cropped nicely */
                }

               
                /* Enhance readability of paragraphs */
                p {
                  margin: 10px 0;
                  line-height: 1.8;
                }

                /* Optional: Add styling for links */
                a {
                    color: #007BFF;
                    text-decoration: none;
                  }
                  a:hover {
                    text-decoration: underline;
                  }

                </style>
              </head>
              <body>
                <div class="banner-container">
                  <img src="$extractedImageUrl" alt="Banner Image" class="banner-image">
                </div>
                <div class="content-container">
                  ${mainContent.outerHtml}
                </div>
              </body>
            </html>
 ''';

      _extractingContentLoadState.value = LoadingStates.loaded;

      // Logger.printLog('[HTML] : ${_extractedContent.value}');
      return mainContent.outerHtml;
    } catch (error) {
      if (kDebugMode) {
        print('Error extracting content: $error');
      }
      _extractingContentLoadState.value = LoadingStates.errorLoading;

      return '<p>Error extracting content</p>';
    }
  }

  void optimizeContent(dom.Element content) {
    // 1. Remove low-value elements
    void removeBoilerplate() {
      // Common patterns for non-article content
      final lowValuePatterns = RegExp(
        r'related|also|popular|trending|recommended|prev|'
        r'share|social|comment|discuss|subscribe|follow|'
        r'sponsor|partner|promotion|read-more|'
        r'more-from|suggested|links|footer',
        caseSensitive: false,
      );

      content.querySelectorAll('*').forEach((element) {
        final classList = element.attributes['class'] ?? '';
        final id = element.attributes['id'] ?? '';
        final text = element.text.trim().toLowerCase();

        // Check if element matches any low-value patterns
        if (lowValuePatterns.hasMatch(classList) ||
                lowValuePatterns.hasMatch(id)
            // lowValuePatterns.hasMatch(text)
            ) {
          // Logger.printLog('[boi] : ${element.outerHtml}');
          element.remove();
        }
      });
    }

    // 2. Clean list items and links
    void cleanListsAndLinks() {
      content.querySelectorAll('ul, ol').forEach((list) {
        final links = list.querySelectorAll('a');
        final items = list.querySelectorAll('li');

        if (items.isNotEmpty && links.length / items.length > 0.4) {
          // Logger.printLog('[REMOVED] Navigation list: ${list.outerHtml}');
          list.remove();
        }
      });

      content.querySelectorAll('a').forEach((link) {
        final visibleText = link.nodes
            .where((node) => node.nodeType == dom.Node.TEXT_NODE)
            .map((node) => node.text)
            .join(' ')
            .trim();

        if (visibleText.isEmpty && link.getElementsByTagName('img').isEmpty) {
          Logger.printLog('[REMOVED] Empty link: ${link.outerHtml}');
          link.remove();
        } else if (visibleText.length > 100) {
          Logger.printLog('[CONVERTED] Long link: ${link.outerHtml}');
          final span = dom.Element.tag('span');
          span.text = visibleText;
          link.replaceWith(span);
        }
      });
    }

    // Helper method to check if elements have similar attributes
    bool haveSimilarAttributes(dom.Element a, dom.Element b) {
      final aClass = a.attributes['class'] ?? '';
      final bClass = b.attributes['class'] ?? '';
      final aStyle = a.attributes['style'] ?? '';
      final bStyle = b.attributes['style'] ?? '';

      return aClass == bClass || aStyle == bStyle;
    }

    // Helper method to check if element is structural
    bool isStructuralElement(dom.Element element) {
      final classList = element.attributes['class'] ?? '';
      final id = element.attributes['id'] ?? '';

      final structuralPatterns = RegExp(
        r'content|main|article|story|post|body',
        caseSensitive: false,
      );

      return structuralPatterns.hasMatch(classList) ||
          structuralPatterns.hasMatch(id);
    }

    // 3. Merge adjacent similar elements
    void mergeAdjacentElements() {
      var elements = content.querySelectorAll('p, div');
      dom.Element? previousElement;

      for (var element in elements) {
        if (previousElement != null &&
            previousElement.localName == element.localName &&
            element.text.trim().isNotEmpty) {
          // Merge if they have similar styles or classes
          if (haveSimilarAttributes(previousElement, element)) {
            previousElement.text = '${previousElement.text} ${element.text}';
            element.remove();
            continue;
          }
        }
        previousElement = element;
      }
    }

    // 4. Remove empty containers
    void removeEmptyContainers() {
      bool hasSignificantContent(dom.Element element) {
        final text = element.text.trim();
        final images = element.getElementsByTagName('img');
        final iframes = element.getElementsByTagName('iframe');

        return text.length > 30 || images.isNotEmpty || iframes.isNotEmpty;
      }

      content.querySelectorAll('div, section, article').forEach((container) {
        if (!hasSignificantContent(container) &&
            container != content && // Don't remove the main content container
            !isStructuralElement(container)) {
          container.remove();
        }
      });
    }

    // 5. Clean up inline styles and attributes
    void cleanInlineContent() {
      content.querySelectorAll('*').forEach((element) {
        // Remove click tracking and analytics attributes
        element.attributes.remove('onclick');
        element.attributes.remove('onload');
        element.attributes.remove('data-tracking');
        element.attributes.remove('data-analytics');

        // Remove empty or redundant style attributes
        final style = element.attributes['style'];
        if (style != null &&
            (style.isEmpty || style.contains('display: block'))) {
          element.attributes.remove('style');
        }

        // Remove common tracking classes
        final classList = element.classes.toList();
        element.classes.removeWhere((className) =>
            className.contains('track') ||
            className.contains('analytics') ||
            className.contains('ga-') ||
            className.contains('data-'));
      });
    }

    // Execute optimizations in sequence
    removeBoilerplate();
    cleanListsAndLinks();
    // ContentCleaner.cleanListsAndLinks(content);
    // mergeAdjacentElements();
    removeEmptyContainers();
    cleanInlineContent();
  }
}

class ContentCleaner {
  // Configuration constants
  static const double _maxLinkDensity = 0.4;
  static const int _maxLinkTextLength = 100;
  static const int _minListItems = 2;
  static const Set<String> _keepClasses = {
    'content-list',
    'article-list',
    'references',
    'citations',
    'footnotes',
  };

  static void cleanListsAndLinks(dom.Element content) {
    _cleanLists(content);
    _cleanLinks(content);
  }

  static bool _shouldKeepList(dom.Element list) {
    final classes = list.classes.map((c) => c.toLowerCase()).toSet();
    return _keepClasses.any((keep) => classes.any((c) => c.contains(keep)));
  }

  static Map<String, dynamic> _calculateListMetrics(dom.Element list) {
    int totalItems = 0;
    int itemsWithLinks = 0;
    int totalLinks = 0;
    int totalTextLength = 0;
    int totalLinkTextLength = 0;
    bool hasImages = false;
    bool hasNumbers = false;
    bool hasDatePatterns = false;

    list.children.forEach((item) {
      totalItems++;
      final itemText = item.text.trim();
      totalTextLength += itemText.length;

      final links = item.getElementsByTagName('a');
      if (links.isNotEmpty) {
        itemsWithLinks++;
        totalLinks += links.length;

        links.forEach((link) {
          totalLinkTextLength += link.text.trim().length;
        });
      }

      if (item.getElementsByTagName('img').isNotEmpty) {
        hasImages = true;
      }

      // Check for numbered patterns (e.g., "1.", "[1]")
      if (RegExp(r'^\d+[\.\]]').hasMatch(itemText)) {
        hasNumbers = true;
      }

      // Check for date patterns
      if (RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(itemText)) {
        hasDatePatterns = true;
      }
    });

    return {
      'totalItems': totalItems,
      'itemsWithLinks': itemsWithLinks,
      'totalLinks': totalLinks,
      'linkDensity': totalItems > 0 ? itemsWithLinks / totalItems : 0,
      'textLinkRatio':
          totalTextLength > 0 ? totalLinkTextLength / totalTextLength : 0,
      'hasImages': hasImages,
      'hasNumbers': hasNumbers,
      'hasDatePatterns': hasDatePatterns,
      'averageTextLength': totalItems > 0 ? totalTextLength / totalItems : 0,
    };
  }

  static bool _shouldRemoveList(Map<String, dynamic> metrics) {
    // Convert values to their proper types to avoid runtime errors
    final bool hasNumbers = metrics['hasNumbers'] as bool;
    final bool hasDatePatterns = metrics['hasDatePatterns'] as bool;
    final bool hasImages = metrics['hasImages'] as bool;
    final double linkDensity = (metrics['linkDensity'] as num).toDouble();
    final double textLinkRatio = (metrics['textLinkRatio'] as num).toDouble();
    final double averageTextLength =
        (metrics['averageTextLength'] as num).toDouble();

    // Keep numbered lists that look like references or citations
    if (hasNumbers && linkDensity > 0) {
      return false;
    }

    // Keep date-based lists (e.g., timelines)
    if (hasDatePatterns) {
      return false;
    }

    // Remove navigation-like lists
    if (linkDensity > _maxLinkDensity && averageTextLength < 50) {
      return true;
    }

    // Remove image galleries
    if (hasImages && linkDensity > 0.8) {
      return true;
    }

    // Remove low-value lists
    return textLinkRatio > 0.8 && averageTextLength < 20;
  }

  static bool _shouldRemoveLink(dom.Element link) {
    final text = link.text.trim();
    final images = link.getElementsByTagName('img');

    // Remove empty links
    if (text.isEmpty && images.isEmpty) {
      return true;
    }

    // Remove common unwanted links
    final href = link.attributes['href']?.toLowerCase() ?? '';
    if (href.contains('javascript:') || href.contains('#') || href == '') {
      return true;
    }

    // Remove social media sharing links
    final linkText = text.toLowerCase();
    if (linkText.contains('share') ||
        linkText.contains('tweet') ||
        linkText.contains('follow')) {
      return true;
    }

    return false;
  }

  static bool _shouldConvertToText(dom.Element link) {
    final text = link.text.trim();

    // Convert long text links to plain text
    if (text.length > _maxLinkTextLength) {
      return true;
    }

    // Convert likely article excerpt links
    if (text.length > 50 && text.contains('. ')) {
      return true;
    }

    // Convert quoted links
    if (text.startsWith('"') && text.endsWith('"')) {
      return true;
    }

    return false;
  }

  static void _cleanLists(dom.Element content) {
    // Create a list of elements to remove
    final listsToRemove = <dom.Element>[];

    // First pass: identify lists to remove
    content.querySelectorAll('ul, ol').forEach((list) {
      if (!_shouldKeepList(list)) {
        final metrics = _calculateListMetrics(list);
        if (_shouldRemoveList(metrics)) {
          listsToRemove.add(list);
        }
      }
    });

    // Second pass: remove identified lists
    for (final list in listsToRemove) {
      list.remove();
    }
  }

  static void _cleanLinks(dom.Element content) {
    // Create lists for different operations
    final linksToRemove = <dom.Element>[];
    final linksToConvert = <dom.Element>[];
    final linksToClean = <dom.Element>[];

    // First pass: categorize links
    content.querySelectorAll('a').forEach((link) {
      if (_shouldRemoveLink(link)) {
        linksToRemove.add(link);
      } else if (_shouldConvertToText(link)) {
        linksToConvert.add(link);
      } else {
        linksToClean.add(link);
      }
    });

    // Second pass: perform operations
    for (final link in linksToRemove) {
      link.remove();
    }

    for (final link in linksToConvert) {
      _convertLinkToText(link);
    }

    for (final link in linksToClean) {
      _cleanLinkContent(link);
    }
  }

  static void _cleanListItems(dom.Element list) {
    final itemsToRemove = <dom.Element>[];
    final nestedListsToProcess = <dom.Element>[];

    // First pass: identify items and nested lists to process
    list.children.forEach((item) {
      if (item.text.trim().isEmpty &&
          item.getElementsByTagName('img').isEmpty) {
        itemsToRemove.add(item);
      }

      item.querySelectorAll('ul, ol').forEach((nestedList) {
        nestedListsToProcess.add(nestedList);
      });
    });

    // Second pass: remove empty items
    for (final item in itemsToRemove) {
      item.remove();
    }

    // Third pass: process nested lists
    for (final nestedList in nestedListsToProcess) {
      final metrics = _calculateListMetrics(nestedList);
      if (_shouldRemoveList(metrics)) {
        nestedList.remove();
      }
    }
  }

  static void _cleanLinkContent(dom.Element link) {
    // Store nodes to remove in a separate list
    final nodesToRemove = <dom.Node>[];

    link.nodes.forEach((node) {
      if (node is dom.Text && node.text.trim().isEmpty) {
        nodesToRemove.add(node);
      }
    });

    // Remove nodes after iteration
    for (final node in nodesToRemove) {
      node.remove();
    }

    // Clean URL if present
    final href = link.attributes['href'];
    if (href != null) {
      try {
        final uri = Uri.parse(href);
        final cleanParams = uri.queryParameters.keys
            .where((key) =>
                !key.contains('utm_') &&
                !key.contains('source') &&
                !key.contains('ref'))
            .toList();

        if (cleanParams.length != uri.queryParameters.length) {
          final cleanUri = uri.replace(
              queryParameters: Map.fromEntries(cleanParams
                  .map((key) => MapEntry(key, uri.queryParameters[key]!))));
          link.attributes['href'] = cleanUri.toString();
        }
      } catch (e) {
        // If URL parsing fails, keep the original URL
        print('Warning: Failed to clean URL $href: $e');
      }
    }
  }

  static void _convertLinkToText(dom.Element link) {
    final span = dom.Element.tag('span');

    // Copy classes safely
    final classesToKeep = link.classes
        .where((c) =>
            c.contains('quote') || c.contains('excerpt') || c.contains('text'))
        .toList();

    if (classesToKeep.isNotEmpty) {
      span.classes.addAll(classesToKeep);
    }

    // Copy nodes safely
    final nodes = link.nodes.toList();
    for (final node in nodes) {
      if (node is dom.Element) {
        if (['b', 'i', 'em', 'strong'].contains(node.localName)) {
          span.append(node.clone(true));
        } else {
          span.text = (span.text ?? '') + node.text;
        }
      } else {
        span.text = (span.text ?? '') + (node.text ?? '');
      }
    }

    link.replaceWith(span);
  }
}
