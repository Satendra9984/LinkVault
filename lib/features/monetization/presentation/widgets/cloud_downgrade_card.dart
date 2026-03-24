import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cloud_downgrade_provider.dart';
import '../providers/subscription_status_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// A Profile page card visible when the user has cancelled their subscription
/// but still has data on the cloud. Offers import-to-device or delete options.
class CloudDowngradeCard extends ConsumerStatefulWidget {
  const CloudDowngradeCard({super.key});

  @override
  ConsumerState<CloudDowngradeCard> createState() => _CloudDowngradeCardState();
}

class _CloudDowngradeCardState extends ConsumerState<CloudDowngradeCard> {
  @override
  Widget build(BuildContext context) {
    final hasMigrated = ref.watch(hasMigratedToCloudProvider);
    final isActive =
        ref.watch(isSubscriptionActiveProvider).valueOrNull ?? true;

    if (!hasMigrated || isActive) return const SizedBox.shrink();

    final downgradeState = ref.watch(cloudDowngradeNotifierProvider);
    final isProcessing = downgradeState.action != DowngradeAction.none &&
        !downgradeState.isComplete;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_off_outlined,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 10),
                Text(
                  'Subscription Inactive',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your data is safe on the cloud. Choose what to do with it:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (downgradeState.error != null) ...[
              const SizedBox(height: 8),
              Text(downgradeState.error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12)),
            ],
            if (isProcessing) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: downgradeState.progress),
              const SizedBox(height: 8),
              Text(downgradeState.message,
                  style: const TextStyle(fontSize: 12)),
            ] else if (downgradeState.isComplete) ...[
              const SizedBox(height: 16),
              Text(downgradeState.message,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(cloudDowngradeNotifierProvider.notifier).reset();
                },
                child: const Text('Dismiss'),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Import to Device'),
                      onPressed: () => ref
                          .read(cloudDowngradeNotifierProvider.notifier)
                          .importFromCloud(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Delete Remote'),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/paywall'),
                  child: const Text('Renew subscription instead'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Remote Data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes all your collections, items, and images from the cloud. '
              'This action CANNOT be undone.\n\nType DELETE to confirm:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Colors.white),
              onPressed: value.text == 'DELETE'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Delete Everything'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(cloudDowngradeNotifierProvider.notifier)
          .deleteRemoteData();
    }
  }
}
