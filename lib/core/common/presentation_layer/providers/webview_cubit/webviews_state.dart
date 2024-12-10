part of 'webviews_cubit.dart';

class WebViewState extends Equatable {
  WebViewState({
    required this.webViewPool,
  });

  // MAPPING FROM {ID : WebViewPoolItem}
  // ID -> {USERID, URLMODELID, COLLECTIONID,}
  final Map<String, WebViewPoolItem> webViewPool;

  WebViewState copyWith({
    required Map<String, WebViewPoolItem> webViewPool,
  }) {
    return WebViewState(
      webViewPool: webViewPool,
    );
  }

  @override
  List<Object> get props => [
        webViewPool,
      ];
}

class WebViewPoolItem extends Equatable{
  final InAppWebViewKeepAlive keepAliveObject; // Manages the WebView lifecycle
  final InAppWebViewController? controller; // Controller for the WebView
  final bool isInUse; // Indicates if this WebView is currently active

  WebViewPoolItem copyWith({
    InAppWebViewController? controller,
    InAppWebViewKeepAlive? keepAliveObject,
    bool? isInUse,
  }) {
    return WebViewPoolItem(
      controller: controller ?? this.controller,
      keepAliveObject: keepAliveObject ?? this.keepAliveObject,
      isInUse: isInUse ?? this.isInUse,
    );
  }

  WebViewPoolItem({
    required this.keepAliveObject,
    this.controller,
    this.isInUse = false,
  });

  @override
  List<Object?> get props => [
        keepAliveObject,
        controller,
        isInUse,
      ];
}
