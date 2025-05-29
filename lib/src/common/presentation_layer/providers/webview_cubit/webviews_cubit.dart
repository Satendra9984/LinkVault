import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

part 'webviews_state.dart';

class WebviewsCubit extends Cubit<WebViewState> {
  WebviewsCubit()
      : super(
          WebViewState(
            webViewPool: {},
          ),
        );

  // GET A WEBVIEWPOOLITEM
  WebViewPoolItem? getWebViewPoolItem(String webViewPoolItemId) {
    final pool = state.webViewPool;

    return pool[webViewPoolItemId];
  }

  /// CREATE OR REUSE A WEBVIEWPOOLITEM
  Future<void> createWebView(String webViewPoolItemId) async {
    final pool = state.webViewPool;

    if (pool.containsKey(webViewPoolItemId)) {
      // Reuse an existing WebView
      emit(
        WebViewState(
          webViewPool: pool,
        ),
      );
    } else {
      // Create a new WebView and add to the pool
      // Will be added later
      // final controller = InAppWebViewController();
      final keepAliveObject = InAppWebViewKeepAlive();

      final newItem = WebViewPoolItem(
        keepAliveObject: keepAliveObject,
        isInUse: true,
      );

      pool[webViewPoolItemId] = newItem;

      emit(
        WebViewState(
          webViewPool: pool,
        ),
      );
    }
  }

  /// UPDATE A WEBVIEW POOL ITEM
  Future<void> updateWebView({
    required String webViewPoolItemId,
    InAppWebViewController? inAppWebViewController,
    InAppWebViewKeepAlive? inAppWebViewKeepAlive,
    bool? isInUse,
  }) async {
    final pool = state.webViewPool;

    if (pool.containsKey(webViewPoolItemId) == false) {
      return;
    }

    final webviewPoolItem = pool[webViewPoolItemId];
    final keepAliveObject = InAppWebViewKeepAlive();

    final newItem = webviewPoolItem?.copyWith(
          controller: inAppWebViewController,
          keepAliveObject: keepAliveObject,
          isInUse: isInUse,
        ) ??
        WebViewPoolItem(
          keepAliveObject: keepAliveObject,
          isInUse: true,
        );

    pool[webViewPoolItemId] = newItem;

    emit(
      WebViewState(
        webViewPool: pool,
      ),
    );
  }

  /// Mark a WebView as no longer in use
  void releaseWebView(String webViewPoolItemId) {
    final pool = state.webViewPool;

    if (pool.containsKey(webViewPoolItemId)) {
      pool.remove(webViewPoolItemId);
      emit(
        WebViewState(
          webViewPool: pool,
        ),
      );
    }
  }
}
