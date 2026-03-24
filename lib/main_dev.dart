import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'bootstrap.dart';

/// Entry point for the DEVELOPMENT flavor.
/// Run with: flutter run --flavor dev -t lib/main_dev.dart
Future<void> main() async {
  await dotenv.load(fileName: '.env.dev');
  await bootstrap();
}
