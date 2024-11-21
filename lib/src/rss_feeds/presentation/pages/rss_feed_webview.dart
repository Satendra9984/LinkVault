import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:link_vault/core/res/colours.dart';
import 'package:html/dom.dart' as dom;

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

  final _isDarkMode = ValueNotifier(false);

  String? readabilityScript;

  final _extractedContent = ValueNotifier("Extracting content...");

  @override
  void initState() {
    super.initState();
    _onlyContentExtraction();

    _loadReadabilityScript();
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

  Future<void> _loadReadabilityScript() async {
    // Load the Readability.js file from assets
    readabilityScript = await rootBundle
        .loadString('assets/js/readability/readabilityjs/Readability.js');
  }

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
                          children: [
                            SizedBox(
                              height: 0.0,
                              child: Expanded(
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
                                      // _onlyContentExtraction();
                                      // Execute the JavaScript extraction script
                                      // final content = await webViewController
                                      //     ?.evaluateJavascript(
                                      //   source: _extractContentScript(),
                                      // );
                                      // Update the extracted content
                                      // if (content != null) {
                                      //   setState(() {
                                      //     extractedContent =
                                      //         content.toString().replaceAll(
                                      //               r'\u003C',
                                      //               '<',
                                      //             ); // Fix escaped HTML
                                      //   });
                                      // }
                                      // if (readabilityScript != null) {
                                      // Inject Readability.js
                                      // await webViewController?.evaluateJavascript(
                                      //   // source: readabilityScript!,
                                      //   // source: _extractFullContentScript(),
                                      //   source: _onlyContentExtraction(),
                                      // );
                              
                                      // Inject the main script for distraction-free reading
                                      // await webViewController?.evaluateJavascript(
                                      //   source: _getDistractionFreeScript(),
                                      // source: _extractFullContentScript(),
                                      // );
                                      // }
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
                                    } catch (e) {
                                      // Logger.printLog('RSS Feed WebView error $e');
                                    }
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
                                      (controller, url, androidIsReload) async {
                                    _url.value = url.toString();
                                    urlController.text = _url.value;
                                    await _updateCanBack(); // Update canGoBack on history update
                                  },
                                  onConsoleMessage: (controller, consoleMessage) {
                                    if (kDebugMode) {
                                      print(consoleMessage);
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: _extractedContent,
                                builder: (context, extractedContent, _) {
                                  return SingleChildScrollView(
                                    padding: EdgeInsets.all(16),
                                    child: HtmlWidget(
                                      extractedContent,
                                      // style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                },
                              ),
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

  String _onlyContentExtraction() {
    return '''
(function () {
  // List of tags to extract meaningful content from the page
  const meaningfulTags = [
    'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'span', 'li', 'blockquote', 'a', 'img'
  ];

  // Helper function to extract meaningful content
  function extractMeaningfulContent(body) {
    const extractedContent = [];

    // Loop through each tag type and collect its content
    meaningfulTags.forEach((tag) => {
      const elements = body.getElementsByTagName(tag);
      Array.from(elements).forEach((element) => {
        if (tag === 'img') {
          // For images, ensure there is a valid 'src' attribute
          if (element.src.trim()) {
            extractedContent.push(`<img src="\${element.src}" alt="\${element.alt || ''}" />`);
          }
        } else if (tag === 'a') {
          // For links, include both href and innerText
          if (element.href.trim() && element.innerText.trim()) {
            extractedContent.push(
              `<a href="\${element.href}">\${element.innerText.trim()}</a>`
            );
          }
        } else {
          // For text-containing elements, include non-empty innerText
          if (element.innerText.trim()) {
            extractedContent.push(element.outerHTML);
          }
        }
      });
    });

    return extractedContent;
  }

  // Main function to extract and update the DOM
  function processContent() {
    try {
      const body = document.body;

      if (!body) {
        return '<p>Content not available</p>';
      }

      // Extract content from meaningful tags
      const extractedContent = extractMeaningfulContent(body);

      // Update the DOM with only the extracted content
      body.innerHTML = extractedContent.join('\n');

      return 'Content extracted and DOM updated successfully';
    } catch (error) {
      console.error('Error processing content:', error);
      return 'Error processing content';
    }
  }

  // Execute and send the result back to Flutter
  const result = processContent();
  
  // Replace document.body with the sanitized content
  document.body.innerHTML = sanitizedContent;

  // Optional: Notify Flutter about the completion
  window.flutter_inappwebview.callHandler('onContentProcessed', result);
})();

''';
  }

  Future<String> extractMainContent(String url) async {
    try {
      // Fetch the HTML content of the page
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load page');
      }

      // Parse the HTML document
      final document = html_parser.parse(utf8.decode(response.bodyBytes));
      final body = document.body;

      if (body == null) {
        return '<p>Content not available</p>';
      }

      // Step 1: Remove unnecessary tags
      void cleanBody(dom.Element body) {
        const unnecessaryTags = [
          'nav',
          'footer',
          'aside',
          'header',
          'script',
          'style',
          'form',
          'input',
        ];
        for (final tag in unnecessaryTags) {
          body.getElementsByTagName(tag).forEach((element) => element.remove());
        }
      }

      // Step 2: Find main content
      dom.Element findMainContent(dom.Element body) {
        return body.querySelector('article') ??
            body.querySelector(
                'div[class*="content"], div[class*="main-content"]') ??
            body.querySelector('section') ??
            body;
      }

      // Step 3: Normalize content
      void normalizeContent(dom.Element body, Uri baseUri) {
        // Remove inline styles and event listeners
        body
            .querySelectorAll('[style], [onclick], [onmouseover]')
            .forEach((element) {
          element.attributes.remove('style');
          element.attributes.remove('onclick');
          element.attributes.remove('onmouseover');
        });

        // Normalize relative links
        body.querySelectorAll('a[href]').forEach((link) {
          final href = link.attributes['href'];
          if (href != null && !href.startsWith('http')) {
            link.attributes['href'] = baseUri.resolve(href).toString();
          }
        });
      }

      // Apply cleaning and normalization
      cleanBody(body);
      final mainContent = findMainContent(body);
      normalizeContent(mainContent, Uri.parse(url));

      // Return the sanitized HTML as a string
      _extractedContent.value = mainContent.outerHtml;
      return mainContent.outerHtml;
    } catch (error) {
      print('Error extracting content: $error');
      return '<p>Error extracting content</p>';
    }
  }

  String _getDistractionFreeScript() {
    return '''
    (function() {
      // Remove unwanted elements
      const selectorsToRemove = [
        ".sidebar", ".advertisement", ".ad", ".promo", ".popup"
      ];

      selectorsToRemove.forEach(selector => {
        document.querySelectorAll(selector).forEach(el => el.remove());
      });

      // Apply Readability if available
      if (typeof Readability !== 'undefined') {
        const article = new Readability(document).parse();
        if (article && article.content) {
          document.body.innerHTML = article.content;
        }
      } else {
        // Fallback content extraction if Readability is not available
        const mainContentSelectors = ["article", "main", ".content", ".post", ".article-body"];
        let mainContent = null;

        mainContentSelectors.some(selector => {
          mainContent = document.querySelector(selector);
          return mainContent !== null;
        });

        if (mainContent) {
          document.body.innerHTML = mainContent.outerHTML;
        }
      }

      // Inject basic CSS for readability and responsive images
      const style = document.createElement('style');
      style.innerHTML = \`
        body {
          margin: 0;
          padding: 20px;
          font-family: Arial, sans-serif;
          font-size: 18px;
          line-height: 1.6;
          color: #333;
          background-color: #f9f9f9;
        }

        p {
          margin: 1em 0;
        }

        h1, h2, h3, h4 {
          font-weight: bold;
          color: #222;
          margin-top: 1.5em;
          margin-bottom: 0.5em;
        }

        img {
          max-width: 100%;
          height: auto;
          display: block;
          margin: 1em auto;
        }

        figure {
          margin: 1em 0;
        }

        figure img {
          max-width: 100%;
          height: auto;
        }

        figcaption {
          font-size: 0.9em;
          color: #666;
          text-align: center;
        }
      \`;
      document.head.appendChild(style);
    })();
  ''';
  }

  PreferredSize _getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showAppBar,
        builder: (context, isVisible, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isVisible ? kToolbarHeight + 16 : 0.0,
            child: isVisible
                ? AppBar(
                    title: Text(
                      widget.url,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
