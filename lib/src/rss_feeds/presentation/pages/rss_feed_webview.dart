import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:link_vault/core/res/colours.dart';
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
  );

  PullToRefreshController? pullToRefreshController;
  final _url = ValueNotifier('');
  final _progress = ValueNotifier<double>(0);
  final urlController = TextEditingController();

  final _isDarkMode = ValueNotifier(false);

  String? readabilityScript;

  @override
  void initState() {
    super.initState();
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
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                        initialSettings: settings,
                        pullToRefreshController: pullToRefreshController,
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
                          if (readabilityScript != null) {
                            // Inject Readability.js
                            await webViewController?.evaluateJavascript(
                              source: readabilityScript!,
                            );

                            // Inject the main script for distraction-free reading
                            await webViewController?.evaluateJavascript(
                              source: _getDistractionFreeScript(),
                            );
                          }
                          await pullToRefreshController?.endRefreshing();
                          _url.value = url.toString();
                          urlController.text = _url.value;

                          await _detectDarkMode();
                          await _updateCanBack(); // Update canGoBack on page load
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

//   String _getDistractionFreeScript() {
//     return '''
// (function() {
//   // Function to find the most likely article container using content density analysis
//   const findArticleContainer = () => {
//     // Elements that typically contain the main article content
//     const possibleContainers = Array.from(document.querySelectorAll(
//       'article, [role="article"], [itemprop="articleBody"], .post-content, .article-content, ' +
//       '.entry-content, .article-body, .post-body, main, #main-content, .main-content, .content, .post'
//     ));

//     let bestContainer = null;
//     let highestScore = 0;

//     possibleContainers.forEach(container => {
//       // Skip invisible elements
//       if (container.offsetParent === null) return;

//       // Calculate content density score
//       const paragraphs = container.getElementsByTagName('p');
//       const links = container.getElementsByTagName('a');
//       const images = container.getElementsByTagName('img');

//       let score = 0;

//       // Text content analysis
//       const textDensity = container.textContent.length / Math.max(1, container.getElementsByTagName('*').length);
//       score += textDensity * 0.3;

//       // Paragraph analysis
//       score += paragraphs.length * 2;

//       // Image analysis (excluding small icons)
//       const contentImages = Array.from(images).filter(img => {
//         const rect = img.getBoundingClientRect();
//         return rect.width > 100 || rect.height > 100;
//       });
//       score += contentImages.length * 1.5;

//       // Link density penalty (to avoid navigation areas)
//       const linkDensity = links.length / Math.max(1, paragraphs.length);
//       score -= linkDensity * 0.5;

//       // Boost score for elements with article-related identifiers
//       const identifier = (container.className + ' ' + container.id).toLowerCase();
//       if (identifier.includes('article') || identifier.includes('post')) {
//         score *= 1.25;
//       }

//       if (score > highestScore) {
//         highestScore = score;
//         bestContainer = container;
//       }
//     });

//     return bestContainer;
//   };

//   // Function to extract clean content while preserving essential interactive elements
//   const extractCleanContent = (container) => {
//     if (!container) return null;

//     const article = document.createElement('article');
//     article.className = 'extracted-content';

//     // Helper to check if an element is likely to be part of the main content
//     const isContentElement = (el) => {
//       const tagName = el.tagName.toLowerCase();
//       const classId = (el.className + ' ' + el.id).toLowerCase();

//       // Skip elements that are likely to be peripheral
//       if (classId.match(/comment|sidebar|footer|nav|menu|author|related|share|social|ad|promo|recommend/i)) {
//         return false;
//       }

//       // Keep essential interactive elements
//       if (['a', 'button', 'video', 'iframe', 'audio'].includes(tagName)) {
//         return true;
//       }

//       // Keep content elements
//       if (['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'img', 'ul', 'ol', 'li',
//            'blockquote', 'pre', 'code', 'table', 'figure', 'figcaption'].includes(tagName)) {
//         return true;
//       }

//       // Keep divs/sections that contain substantial content
//       if (['div', 'section'].includes(tagName)) {
//         const hasSubstantialText = el.textContent.trim().length > 50;
//         const hasContentElements = el.querySelector('p, img, video, iframe');
//         return hasSubstantialText || hasContentElements;
//       }

//       return false;
//     };

//     // Process a node and its children
//     const processNode = (node) => {
//       // Handle text nodes
//       if (node.nodeType === Node.TEXT_NODE) {
//         const text = node.textContent.trim();
//         return text ? node.cloneNode(true) : null;
//       }

//       // Handle element nodes
//       if (node.nodeType === Node.ELEMENT_NODE) {
//         // Skip script and style elements
//         if (['script', 'style', 'noscript'].includes(node.tagName.toLowerCase())) {
//           return null;
//         }

//         // Special handling for images
//         if (node.tagName === 'IMG') {
//           const rect = node.getBoundingClientRect();
//           // Keep only content images (exclude tiny icons)
//           if (rect.width > 100 || rect.height > 100) {
//             const img = node.cloneNode(true);
//             img.setAttribute('loading', 'lazy');
//             return img;
//           }
//           return null;
//         }

//         // Special handling for iframes (mainly for videos)
//         if (node.tagName === 'IFRAME') {
//           const src = node.src.toLowerCase();
//           const videoSites = ['youtube.com', 'vimeo.com', 'dailymotion.com'];
//           if (videoSites.some(site => src.includes(site))) {
//             const wrapper = document.createElement('div');
//             wrapper.className = 'video-wrapper';
//             const iframe = node.cloneNode(true);
//             wrapper.appendChild(iframe);
//             return wrapper;
//           }
//           return null;
//         }

//         // Process other elements
//         if (isContentElement(node)) {
//           const newElement = document.createElement(node.tagName);

//           // Copy essential attributes
//           ['class', 'id', 'href', 'src', 'alt', 'title', 'target'].forEach(attr => {
//             if (node.hasAttribute(attr)) {
//               newElement.setAttribute(attr, node.getAttribute(attr));
//             }
//           });

//           // Process child nodes
//           node.childNodes.forEach(child => {
//             const processedChild = processNode(child);
//             if (processedChild) {
//               newElement.appendChild(processedChild);
//             }
//           });

//           // Only keep elements that have content after processing
//           if (newElement.textContent.trim() || newElement.querySelector('img, video, iframe')) {
//             return newElement;
//           }
//         }
//       }

//       return null;
//     };

//     // Process all children of the container
//     container.childNodes.forEach(child => {
//       const processedNode = processNode(child);
//       if (processedNode) {
//         article.appendChild(processedNode);
//       }
//     });

//     return article;
//   };

//   // Apply clean, readable styles
//   const applyStyles = () => {
//     const style = document.createElement('style');
//     style.textContent = `
//       body {
//         margin: 0 auto;
//         padding: 20px;
//         max-width: 800px;
//         font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
//         font-size: 18px;
//         line-height: 1.6;
//         color: #333;
//         background: #fff;
//       }
//       .extracted-content {
//         width: 100%;
//       }
//       p, ul, ol {
//         margin-bottom: 1em;
//       }
//       img {
//         max-width: 100%;
//         height: auto;
//         margin: 1em auto;
//         display: block;
//       }
//       .video-wrapper {
//         position: relative;
//         padding-bottom: 56.25%;
//         height: 0;
//         overflow: hidden;
//         margin: 1em 0;
//       }
//       .video-wrapper iframe {
//         position: absolute;
//         top: 0;
//         left: 0;
//         width: 100%;
//         height: 100%;
//       }
//       a {
//         color: #0066cc;
//         text-decoration: none;
//       }
//       a:hover {
//         text-decoration: underline;
//       }
//       pre, code {
//         background: #f5f5f5;
//         padding: 0.2em 0.4em;
//         border-radius: 3px;
//         font-family: monospace;
//         overflow-x: auto;
//       }
//       blockquote {
//         margin: 1em 0;
//         padding-left: 1em;
//         border-left: 4px solid #ddd;
//         color: #666;
//       }
//       table {
//         width: 100%;
//         border-collapse: collapse;
//         margin: 1em 0;
//       }
//       th, td {
//         border: 1px solid #ddd;
//         padding: 8px;
//       }
//     `;
//     document.head.appendChild(style);
//   };

//   // Main execution
//   try {
//     // Find the main article container
//     const articleContainer = findArticleContainer();

//     if (articleContainer) {
//       // Extract clean content
//       const cleanContent = extractCleanContent(articleContainer);

//       if (cleanContent && cleanContent.textContent.trim()) {
//         // Clear the page and insert clean content
//         document.body.innerHTML = '';
//         document.body.appendChild(cleanContent);
//         applyStyles();
//         window.scrollTo(0, 0);
//       }
//     }
//   } catch (error) {
//     console.error('Error extracting content:', error);
//   }
// })();
//     ''';
//   }

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
