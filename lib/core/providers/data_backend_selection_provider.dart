import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/monetization/presentation/providers/subscription_status_provider.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import 'network_providers.dart';

class DataBackendSelection {
  final bool useCloud;
  final bool isReadOnlyCloud;
  final String? supabaseUserId;

  const DataBackendSelection({
    required this.useCloud,
    required this.isReadOnlyCloud,
    required this.supabaseUserId,
  });
}

/// Canonical ADR-0002 backend routing used by collections + items providers.
final dataBackendSelectionProvider = Provider<DataBackendSelection>((ref) {
  final hasMigratedToCloud = ref.watch(hasMigratedToCloudProvider);
  final currentUser = ref.watch(currentUserProvider);
  final isOnline = ref.watch(isOnlineProvider);
  final isPremium = ref.watch(isPremiumProvider);
  final isActive =
      ref.watch(isSubscriptionActiveProvider).valueOrNull ?? false;

  final isAuthenticated = currentUser != null;
  final useCloud = isAuthenticated && isOnline && (!isPremium || hasMigratedToCloud);
  final supabaseUserId = currentUser?.supabaseId;
  final isReadOnlyCloud = useCloud && isPremium && !isActive;

  return DataBackendSelection(
    useCloud: useCloud,
    isReadOnlyCloud: isReadOnlyCloud,
    supabaseUserId: supabaseUserId,
  );
});
