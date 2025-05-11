// ignore_for_file: public_member_api_docs

import 'package:go_router/go_router.dart';
import 'package:link_vault/routing/route_paths.dart';

/// Abstract navigation service interface
abstract class NavigationService {
  /// Navigate to a new route by replacing the current one
  void navigateTo(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? extra,
  });

  /// Navigate to a route and replace the current history entry
  void replaceTo(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? extra,
  });

  /// Navigate back to the previous route
  void navigateBack();

  /// Navigate to the home screen
  void navigateToHome();

  /// Navigate to the login screen
  void navigateToLogin({String? returnPath});

  /// Navigate to a product detail page
  // void navigateToProductDetail(String productId, {bool isEditing = false});
}

/// Implementation of navigation service using GoRouter
class GoRouterNavigationService implements NavigationService {

  GoRouterNavigationService(this._router);
  
  final GoRouter _router;

  @override
  void navigateTo(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    _router.go(
      _buildPath(path, queryParams),
      extra: extra,
    );
  }

  @override
  void replaceTo(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    _router.replace(
      _buildPath(path, queryParams),
      extra: extra,
    );
  }

  @override
  void navigateBack() {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(RoutePaths.home);
    }
  }

  @override
  void navigateToHome() {
    _router.go(RoutePaths.home);
  }

  @override
  void navigateToLogin({String? returnPath}) {
    if (returnPath != null) {
      _router.go('${RoutePaths.login}?returnToPath=$returnPath');
    } else {
      _router.go(RoutePaths.login);
    }
  }

  // @override
  // void navigateToProductDetail(String productId, {bool isEditing = false}) {
  //   final path = RoutePaths.productDetailPath(productId);
  //   if (isEditing) {
  //     _router.go(path, extra: {'isEditing': true});
  //   } else {
  //     _router.go(path);
  //   }
  // }

  // Helper to build path with query parameters
  String _buildPath(String path, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return path;
    }

    final uri = Uri.parse(path);
    final newUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParams.map((key, value) => MapEntry(key, value.toString())),
      },
    );

    return newUri.toString();
  }
}
