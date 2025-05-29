// ==========================================
// File: core/services/deeplink_service.dart
// ==========================================
import 'dart:async';
import 'package:app_links/app_links.dart';

abstract class DeepLinkService {
  Stream<Uri> get linkStream;
  Future<Uri?> getInitialLink();
  void dispose();
}

class DeepLinkServiceImpl implements DeepLinkService {
  StreamSubscription<Uri>? _linkSubscription;
  final StreamController<Uri> _linkController =
      StreamController<Uri>.broadcast();

  @override
  Stream<Uri> get linkStream => _linkController.stream;

  DeepLinkServiceImpl() {
    _initialize();
  }

  void _initialize() {
    _linkSubscription = AppLinks().uriLinkStream.listen(
      (Uri uri) => _linkController.add(uri),
      onError: (err) {
        // Log error
        print('DeepLink Error: $err');
      },
    );
  }

  @override
  Future<Uri?> getInitialLink() async {
    try {
      return await AppLinks().getInitialLink();
    } catch (e) {
      print('Initial Link Error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}
