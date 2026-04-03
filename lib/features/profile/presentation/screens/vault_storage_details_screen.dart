import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/infrastructure/storage/local_vault_storage_summary.dart';
import '../providers/local_storage_usage_provider.dart';

/// Full breakdown of on-device LinkVault storage (ObjectBox + images).
class VaultStorageDetailsScreen extends ConsumerWidget {
  const VaultStorageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local storage'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.invalidate(localVaultStorageUsageProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ref.watch(localVaultStorageUsageProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      'Couldn’t read storage sizes. Your library still works as usual.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.tonal(
                      onPressed: () =>
                          ref.invalidate(localVaultStorageUsageProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
            data: (summary) {
              final tier = vaultStorageTier(summary.totalBytes);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'On-device data used by LinkVault (offline library and cached images). '
                    'Cloud sync does not add to this figure.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Local data: ${formatVaultStorageBytes(summary.totalBytes)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Database: ${formatVaultStorageBytes(summary.objectboxBytes)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Images & files: ${formatVaultStorageBytes(summary.imagesBytes)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tier.$1,
                      minHeight: 6,
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tier.$2} local library — scale is relative to typical use, not your device storage.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Use Export, Import, or Clear all data on Profile to move or remove this library.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
