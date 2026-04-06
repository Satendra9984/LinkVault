import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_notifier.dart';

/// Dedicated screen explaining LinkVault-only vs full account deletion.
/// Route: `/profile/account-deletion`.
class AccountDeletionScreen extends ConsumerWidget {
  const AccountDeletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Account & data'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const SizedBox(height: 8),
          Icon(
            Icons.shield_outlined,
            size: 48,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Manage your account',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Understand what each option removes before you continue.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'REMOVE LINKVAULT DATA'),
          _DeletionOptionCard(
            icon: Icons.delete_sweep_outlined,
            title: 'Delete LinkVault data only',
            chipLabels: const ['Keeps your account', 'All apps safe'],
            deletedBullets: const [
              'All saved links and collections (cloud + local)',
              'Your LinkVault profile and avatar',
              'Uploaded images (item thumbnails, avatar files)',
            ],
            keptBullets: const [
              'Your login (email / Google / Apple)',
              'Access to Curate and other shared-account apps',
            ],
            buttonLabel: 'Delete LinkVault data',
            onConfirm: () => _confirmDeleteLinkVaultData(context, ref),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'DELETE ENTIRE ACCOUNT'),
          _DeletionOptionCard(
            icon: Icons.delete_forever_outlined,
            title: 'Delete entire account',
            chipLabels: const ['Cannot be undone', 'Affects all apps'],
            deletedBullets: const [
              'Everything in “Delete LinkVault data only”',
              'Your login and identity across all linked apps',
              'Curate data associated with this account',
            ],
            keptBullets: const [],
            afterBullets: const [
              'You will be signed out everywhere',
              'You can create a new account with the same email',
            ],
            buttonLabel: 'Delete entire account',
            onConfirm: () => _confirmDeleteEntireAccount(context, ref),
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmDeleteLinkVaultData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete LinkVault data?'),
        content: const Text(
          'This permanently removes your LinkVault cloud data and signs you out of this app. '
          'Your account stays active for other apps. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete LinkVault data'),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      await ref.read(profileNotifierProvider.notifier).deleteLinkVaultDataOnly();
    }
  }

  static Future<void> _confirmDeleteEntireAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entire account?'),
        content: const Text(
          'This permanently deletes your shared account across all apps, including LinkVault and Curate. '
          'You will lose access everywhere. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete entire account'),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      await ref.read(profileNotifierProvider.notifier).deleteEntireAccount();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DeletionOptionCard extends StatelessWidget {
  const _DeletionOptionCard({
    required this.icon,
    required this.title,
    required this.chipLabels,
    required this.deletedBullets,
    required this.keptBullets,
    this.afterBullets = const [],
    required this.buttonLabel,
    required this.onConfirm,
  });

  final IconData icon;
  final String title;
  final List<String> chipLabels;
  final List<String> deletedBullets;
  final List<String> keptBullets;
  final List<String> afterBullets;
  final String buttonLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final error = cs.error;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: cs.errorContainer.withValues(alpha: 0.18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: error, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chipLabels
                    .map(
                      (label) => Chip(
                        label: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        backgroundColor: cs.errorContainer,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              Divider(height: 24, color: error.withValues(alpha: 0.25)),
              Text(
                "What's deleted",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...deletedBullets.map((t) => _BulletLine(text: t)),
              if (keptBullets.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  "What's kept",
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...keptBullets.map((t) => _BulletLine(text: t)),
              ],
              if (afterBullets.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'After deletion',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...afterBullets.map((t) => _BulletLine(text: t)),
              ],
              Divider(height: 24, color: error.withValues(alpha: 0.25)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onConfirm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: error,
                    side: BorderSide(color: error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
