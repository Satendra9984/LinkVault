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

    switch (uri.path) {
      case '/email-verification':
        _handleEmailVerification(uri);
      // case '/password-reset':
      //   _handlePasswordReset(uri);
      default:
        // Handle unknown deeplinks - maybe navigate to home
        _navigationService.go(RoutePaths.splash);
    }
  }

  void _handleEmailVerification(Uri uri) {
    final token = uri.queryParameters['code'];

    if (token != null && token.isNotEmpty) {
      _navigationService.go(
        '${RoutePaths.signUp}${RoutePaths.emailVerification}?token=${Uri.encodeComponent(token)}',
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
