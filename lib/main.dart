import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'bootstrap.dart';

/// Canonical entrypoint for Sprint 1–2.
///
/// Loads the correct env file based on the `--dart-define=FLAVOR=...` value
/// provided by the flavor run config, then bootstraps ObjectBox + Supabase.
Future<void> main() async {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final envFile = flavor == 'production' ? '.env.production' : '.env.dev';

  await dotenv.load(fileName: envFile);
  await bootstrap();
}
