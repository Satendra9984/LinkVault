import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ad_gate_provider.dart';

/// Full-screen gate shown when the free-trial window has passed and no valid
/// DayPass is active. Blocks access until the user:
///   • Watches a rewarded ad  (grants 24-hr DayPass), or
///   • Upgrades to Premium    (bypasses gate forever).
class AdGateScreen extends ConsumerWidget {
  const AdGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateAsync = ref.watch(adGateProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Navigate away once access is granted (status changed to active/freeTrial/premium).
    ref.listen<AsyncValue<DayPassStatus>>(adGateProvider, (_, next) {
      next.whenData((status) {
        if (status != DayPassStatus.expired && context.mounted) {
          context.go('/');
        }
      });
    });

    final isLoading = gateAsync.isLoading || gateAsync.valueOrNull == null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon ─────────────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_num_rounded,
                  size: 52,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 32),

              // ── Headline ─────────────────────────────────────────────────
              Text(
                'Daily Access Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Your free trial has ended. Watch a short ad each day to keep '
                'full access to LinkVault, or upgrade to Premium for an ad-free '
                'experience forever.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── Watch Ad Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await ref
                              .read(adGateProvider.notifier)
                              .watchAdForAccess();
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_outline_rounded),
                  label: Text(
                    isLoading ? 'Loading ad…' : 'Watch Ad – Get Daily Access',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Go Premium Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final upgraded =
                              await context.push<bool>('/paywall') ?? false;
                          if (upgraded && context.mounted) {
                            // Refresh gate status — premium will bypass
                            await ref.read(adGateProvider.notifier).refresh();
                          }
                        },
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text(
                    'Go Premium – No Ads Forever',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Grace period info ─────────────────────────────────────────
              if (gateAsync.valueOrNull == DayPassStatus.grace)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 18, color: cs.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'re in grace period (offline or ad unavailable). '
                          'Full access is still available.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
