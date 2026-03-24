import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable card shown when a free/guest user taps into a premium-only area.
/// Displays a brief description and a CTA button to the paywall.
class UpgradePromptWidget extends StatelessWidget {
  /// Short description of what the feature does.
  final String featureName;

  /// Larger icon to illustrate the locked feature.
  final IconData icon;

  const UpgradePromptWidget({
    super.key,
    required this.featureName,
    this.icon = Icons.workspace_premium_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              'Premium Feature',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              featureName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text(
                'Upgrade to Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
