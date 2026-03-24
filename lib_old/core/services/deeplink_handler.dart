// ==========================================
// File: core/services/deeplink_handler.dart
// ==========================================
import 'package:go_router/go_router.dart';
import 'package:link_vault/core/services/deeplink_service.dart';
import 'package:link_vault/routing/route_paths.dart';

class DeepLinkHandler {
  DeepLinkHandler({
    required DeepLinkService deepLinkService,
    required GoRouter navigationService,
  })  : _deepLinkService = deepLinkService,
        _navigationService = navigationService;
  final DeepLinkService _deepLinkService;
  final GoRouter _navigationService;

  void initialize() {
    _handleInitialLink();
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    final initialLink = await _deepLinkService.getInitialLink();
    if (initialLink != null) {
      _processDeepLink(initialLink);
    }
  }

  void _handleIncomingLinks() {
    _deepLinkService.linkStream.listen(
      _processDeepLink,
    );
  }

  void _processDeepLink(Uri uri) {
    // 1) If Supabase gave us something like com.vicharshala.linkvault:/?code=XYZ
    //    then uri.path == "/" and uri.queryParameters['code'] is non-null.
    //    Treat this as an email‐verification flow.
    final String? deepLinkCode = uri.queryParameters['code'];
    if (deepLinkCode != null && deepLinkCode.isNotEmpty) {
      _handleEmailVerification(uri);
      return;
    }

    // 2) Otherwise, maybe Supabase (or your other logic) uses an explicit path,
    //    e.g. com.vicharshala.linkvault://email-verification?code=XYZ
    switch (uri.path) {
      case '/email-verification':
        _handleEmailVerification(uri);
        break;

      // You can uncomment this if you ever need password‐reset handling:
      // case '/password-reset':
      //   _handlePasswordReset(uri);
      //   break;
    }
  }

  void _handleEmailVerification(Uri uri) {
    final token = uri.queryParameters['code'];

    if (token != null && token.isNotEmpty) {
      _navigationService.go(
        '${RoutePaths.signUp}${RoutePaths.emailVerification}?code=${Uri.encodeComponent(token)}',
      );
    }
  }

  // void _handlePasswordReset(Uri uri) {
  //   final token = uri.queryParameters['token'];
  //   if (token != null) {
  //     _navigationService.go(
  //       '${RoutePaths.login}/${RoutePaths.forgetPassword}?token=${Uri.encodeComponent(token)}',
  //     );
  //   }
  // }

  void dispose() {
    _deepLinkService.dispose();
  }
}
