import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/services/storage_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export '/src/splash/splash_injection_providers.dart';

final supabaseClientProvider = StateProvider<SupabaseClient?>((ref) => null);

final isarProvider = StateProvider<Isar?>((ref) => null);

final storageServiceProvider = Provider(
  (ref) {
    return StorageService();
  },
);
