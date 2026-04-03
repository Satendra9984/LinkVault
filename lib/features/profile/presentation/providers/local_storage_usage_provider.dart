import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/infrastructure/storage/local_vault_storage_summary.dart';

/// Snapshot of local ObjectBox + images folder sizes (async, refreshed on demand).
final localVaultStorageUsageProvider =
    FutureProvider<LocalVaultStorageSummary>((ref) async {
  return measureLocalVaultStorage();
});
