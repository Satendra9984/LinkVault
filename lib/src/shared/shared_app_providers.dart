import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
<<<<<<< HEAD
import 'package:link_vault/core/services/app_initialization_service.dart';
import 'package:link_vault/core/services/deeplink_handler.dart';
import 'package:link_vault/core/services/deeplink_service.dart';
import 'package:link_vault/core/services/storage_services.dart';
import 'package:link_vault/routing/app_router.dart';
=======
import 'package:link_vault/core/services/storage_services.dart';
>>>>>>> b5af7d0d72fe3290112f11fa2a3df99dc54f675d
import 'package:supabase_flutter/supabase_flutter.dart';


final supabaseClientProvider = StateProvider<SupabaseClient?>((ref) => null);

final isarProvider = StateProvider<Isar?>((ref) => null);

final storageServiceProvider = Provider(
  (ref) {
    return StorageService();
  },
);
<<<<<<< HEAD

final deepLinkServiceProvider = Provider<DeepLinkService>(
  (ref) => DeepLinkServiceImpl(),
);

final deepLinkHandlerProvider = Provider<DeepLinkHandler>(
  (ref) => DeepLinkHandler(
    deepLinkService: ref.watch(deepLinkServiceProvider),
    navigationService: ref.watch(routeProvider),
  ),
);

final appInitializationServiceProvider = Provider<AppInitializationService>(
  (ref) => AppInitializationService(
    deepLinkHandler: ref.watch(deepLinkHandlerProvider),
  ),
);
=======
>>>>>>> b5af7d0d72fe3290112f11fa2a3df99dc54f675d
