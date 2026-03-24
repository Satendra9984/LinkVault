import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'bootstrap.dart';

/// Entry point for the PRODUCTION flavor.
/// Run with:   flutter run --flavor production -t lib/main_production.dart
/// Build with: flutter build apk --flavor production -t lib/main_production.dart --release
Future<void> main() async {
  await dotenv.load(fileName: '.env.production');
  await bootstrap();
}
