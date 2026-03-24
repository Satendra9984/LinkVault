import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/subscription_status_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// A persistent warning banner shown at the top of the main scaffold
/// when a user's subscription has lapsed but their data lives on the cloud.
///
/// Hides itself automatically when the subscription becomes active again.
class SubscriptionExpiredBanner extends ConsumerWidget {
  const SubscriptionExpiredBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasMigrated = ref.watch(hasMigratedToCloudProvider);
    final isActive =
        ref.watch(isSubscriptionActiveProvider).valueOrNull ?? true;

    // Only show when user has cloud data but subscription lapsed
    if (!hasMigrated || isActive) return const SizedBox.shrink();

    return Material(
      elevation: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        color: Colors.amber.shade700,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Subscription expired. Your cloud data is safe — renew to resume editing.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Renew',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
