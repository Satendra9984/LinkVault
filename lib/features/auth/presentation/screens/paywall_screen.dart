import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../monetization/domain/entities/subscription_package.dart';
import '../../../monetization/presentation/providers/paywall_view_model.dart';

/// Displays subscription offering fetched from RevenueCat.
/// Shown when a user taps "Go Premium" anywhere in the app.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallAsync = ref.watch(paywallViewModelProvider);

    return Scaffold(
      body: paywallAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(paywallViewModelProvider),
        ),
        data: (state) {
          if (state.status == PaywallStatus.success) {
            // Delay pop so the user sees the success state briefly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.pop(true);
            });
          }

          // Show error as SnackBar
          if (state.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            });
          }

          final packages = state.offering?.packages ?? [];

          return _PaywallContent(
            packages: packages,
            isLoading: state.isPurchasing,
            onPurchase: (package) async {
              ref
                  .read(paywallViewModelProvider.notifier)
                  .selectPackage(package);
              final success = await ref
                  .read(paywallViewModelProvider.notifier)
                  .purchasePackage();
              if (success && context.mounted) context.pop(true);
            },
            onRestore: () async {
              final success = await ref
                  .read(paywallViewModelProvider.notifier)
                  .restorePurchases();
              if (success && context.mounted) {
                context.pop(true);
              } else if (context.mounted && state.errorMessage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No previous purchases found.')),
                );
              }
            },
            onClose: () => context.pop(false),
          );
        },
      ),
    );
  }
}

// ── Paywall Content ────────────────────────────────────────────────────────────

class _PaywallContent extends StatelessWidget {
  final List<SubscriptionPackage> packages;
  final bool isLoading;
  final Future<void> Function(SubscriptionPackage) onPurchase;
  final VoidCallback onRestore;
  final VoidCallback onClose;

  const _PaywallContent({
    required this.packages,
    required this.isLoading,
    required this.onPurchase,
    required this.onRestore,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // ── Hero + Close ─────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: false,
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.primaryContainer,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                ),
                // Icon + headline
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 72,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LinkVault Premium',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sync everything. Access anywhere.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                Positioned(
                  top: 48,
                  right: 16,
                  child: IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.close, color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Features list ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              children: const [
                _FeatureRow(
                    icon: Icons.cloud_sync_rounded,
                    text: 'Cloud sync across all devices'),
                _FeatureRow(
                    icon: Icons.all_inclusive_rounded,
                    text: 'Unlimited collections & items'),
                _FeatureRow(
                    icon: Icons.image_rounded,
                    text: 'High-resolution image storage'),
                _FeatureRow(icon: Icons.block_rounded, text: 'No ads, ever'),
                _FeatureRow(
                    icon: Icons.star_rounded,
                    text: 'Priority support & new features first'),
              ],
            ),
          ),
        ),

        // ── Package cards ─────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PackageCard(
                package: packages[index],
                isLoading: isLoading,
                onTap: () => onPurchase(packages[index]),
              ),
              childCount: packages.length,
            ),
          ),
        ),

        // ── Restore & legal ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              children: [
                TextButton(
                  onPressed: isLoading ? null : onRestore,
                  child: const Text('Restore Purchases'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subscriptions auto-renew. Cancel anytime in your App/Play Store settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Feature Row ────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ── Package Card ───────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final SubscriptionPackage package;
  final bool isLoading;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Extract friendly duration from package type
    String durationLabel = _durationLabel(package.billingPeriod);
    String pricePerPeriod = '${package.priceString} / $durationLabel';

    // Month-equivalent price hint for annual plans
    String? priceHint;
    if (package.billingPeriod == 'annual') {
      // Show monthly equivalent
      final monthly = (package.price / 12);
      priceHint = '${package.currencyCode} ${monthly.toStringAsFixed(2)}/month';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title.replaceAll(RegExp(r'\s*\(.*\)'), ''),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(pricePerPeriod,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.primary)),
                    if (priceHint != null) ...[
                      const SizedBox(height: 2),
                      Text(priceHint,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Subscribe'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _durationLabel(String type) {
    switch (type) {
      case 'monthly':
        return 'month';
      case 'annual':
        return 'year';
      case 'weekly':
        return 'week';
      default:
        return 'period';
    }
  }
}

// ── Error View ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Could not load plans', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
