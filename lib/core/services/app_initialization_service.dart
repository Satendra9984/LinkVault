import 'package:link_vault/core/services/deeplink_handler.dart';

class AppInitializationService {
  final DeepLinkHandler _deepLinkHandler;
  
  AppInitializationService({
    required DeepLinkHandler deepLinkHandler,
  }) : _deepLinkHandler = deepLinkHandler;

  Future<void> initialize() async {
    _deepLinkHandler.initialize();
    
    // Add other initialization logic here:
    // - Firebase initialization
    // - Analytics setup
    // - Crash reporting setup
  }

  void dispose() {
    _deepLinkHandler.dispose();
  }
}