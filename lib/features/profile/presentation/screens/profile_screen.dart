import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/profile_notifier.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../monetization/presentation/providers/ad_gate_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../../core/providers/network_providers.dart';
import '../../../monetization/presentation/widgets/cloud_downgrade_card.dart';
import '../../../sync/presentation/providers/sync_coordinator_provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/infrastructure/storage/local_vault_storage_summary.dart';
import '../providers/local_storage_usage_provider.dart';

/// Google Play listing for in-app “Rate the app”.
final Uri _linkVaultPlayStoreUri = Uri.parse(
  'https://play.google.com/store/apps/details?id=com.vicharshala.link_vault',
);

Future<void> _openPlayStoreForRating(BuildContext context) async {
  try {
    final launched = await launchUrl(
      _linkVaultPlayStoreUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the Play Store.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the Play Store.')),
      );
    }
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    if (authAsync.isLoading) {
      final theme = Theme.of(context);
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Semantics(
            liveRegion: true,
            label: 'Loading profile',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    final isGuest = ref.watch(isGuestProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final theme = Theme.of(context);

    if (isGuest) {
      return _buildGuestPrompt(context, theme);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: profileState.when(
        data: (state) {
          if (state.isLoading) return _buildSettingUpProfileState(context);
          final profile = state.profile;
          if (profile == null) {
            return _buildProfileRecoveryState(
              context,
              ref,
              message: state.errorMessage,
            );
          }
          return _ProfileBody(profile: profile, isPremium: isPremium);
        },
        loading: () => _buildSettingUpProfileState(context),
        error: (err, _) => _buildProfileRecoveryState(
          context,
          ref,
          message: err.toString(),
        ),
      ),
    );
  }

  // ── Loading / Error recovery states ─────────────────────────────────────────

  Widget _buildSettingUpProfileState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Setting up your profile...',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRecoveryState(
    BuildContext context,
    WidgetRef ref, {
    String? message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'We could not load your profile right now.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null && message.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  ref.read(profileNotifierProvider.notifier).retryLoadProfile(),
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Guest prompt ─────────────────────────────────────────────────────────────

  Widget _buildGuestPrompt(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Create an account', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Sign up to sync collections, share with friends, and customize your profile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    context.push('/auth/email', extra: AppOtpType.signup),
                child: const Text('Create Account'),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/auth/email', extra: AppOtpType.magiclink),
                child: const Text('Already have an account? Sign in'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile body — owns all the sections ────────────────────────────────────

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.profile, required this.isPremium});

  final dynamic profile;
  final bool isPremium;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  bool _dataBusy = false;

  void _dismissProgressIfOpen(BuildContext context) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  Widget _cloudSyncSection(BuildContext context, WidgetRef ref) {
    final migrated = ref.watch(hasMigratedToCloudProvider);
    if (!migrated) return const SizedBox.shrink();
    final sync = ref.watch(syncCoordinatorProvider);
    final theme = Theme.of(context);
    String two(int n) => n.toString().padLeft(2, '0');
    String fmt(DateTime t) {
      final l = t.toLocal();
      return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: 'CLOUD SYNC'),
        _Card(
          child: ListTile(
            leading: Icon(
              sync.isRunning
                  ? Icons.sync
                  : sync.lastError != null
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_sync_outlined,
            ),
            title: const Text('Sync status'),
            subtitle: Text(
              sync.isRunning
                  ? 'Syncing with cloud…'
                  : sync.lastError != null
                      ? sync.lastError!
                      : sync.lastSuccessAt != null
                          ? 'Last OK: ${fmt(sync.lastSuccessAt!)} — ~${sync.pendingApprox} pending (local)'
                          : 'Tap to run a manual sync',
              style: theme.textTheme.bodySmall,
            ),
            trailing: sync.isRunning
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: 'Sync now',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref
                        .read(syncCoordinatorProvider.notifier)
                        .runSync(manual: true),
                  ),
            onTap: sync.isRunning
                ? null
                : () => ref
                    .read(syncCoordinatorProvider.notifier)
                    .runSync(manual: true),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = widget.profile;
    final isPremium = widget.isPremium;
    final username = (profile.username as String?) ?? '';

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const CloudDowngradeCard(),
        _cloudSyncSection(context, ref),

        // ── User card ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: cs.surfaceContainerHighest,
                      child: profile.avatarUrl != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: profile.avatarUrl as String,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Icon(
                                  Icons.person,
                                  size: 30,
                                  color: cs.onSurfaceVariant,
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 30,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            )
                          : const Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName as String? ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (username.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('@$username',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                )),
                          ],
                          Consumer(builder: (context, ref, _) {
                            final email = ref.watch(currentUserProvider)?.email;
                            if (email == null || email.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              email,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            );
                          }),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/profile/edit'),
                      child: const Text('Edit →'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Subscription ──────────────────────────────────────────────
        _SectionHeader(title: 'SUBSCRIPTION'),
        _Card(
          child: isPremium
              ? ListTile(
                  leading: Icon(Icons.star_rounded, color: Colors.amber[700]),
                  title: const Text('Premium'),
                  subtitle: const Text('Cloud sync active'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => context.push('/paywall'),
                )
              : ListTile(
                  leading: const Icon(Icons.star_outline_rounded),
                  title: const Text('Free tier'),
                  subtitle: const Text('Watching 1 ad/day'),
                  trailing: FilledButton.tonal(
                    onPressed: () => context.push('/paywall'),
                    child: const Text('Upgrade'),
                  ),
                ),
        ),

        // ── Storage (local ObjectBox + images) ────────────────────────
        _SectionHeader(title: 'STORAGE'),
        _Card(
          child: ListTile(
            leading: const Icon(Icons.sd_storage_outlined),
            title: const Text('Local storage'),
            subtitle: ref.watch(localVaultStorageUsageProvider).when(
              loading: () => Text(
                'Measuring…',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              error: (_, __) => Text(
                'Couldn’t measure — tap for details',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              data: (summary) {
                final tier = vaultStorageTier(summary.totalBytes);
                return Text(
                  '${formatVaultStorageBytes(summary.totalBytes)} · ${tier.$2}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                );
              },
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => context.push('/profile/storage'),
          ),
        ),

        // ── Preferences ───────────────────────────────────────────────
        _SectionHeader(title: 'PREFERENCES'),
        _Card(
          child: Column(
            children: [
              _SettingsTile(
                label: 'Theme',
                trailing: _ThemeValueText(ref: ref),
                onTap: () => context.push('/profile/settings'),
                showDivider: false,
              ),
              // _SettingsTile(
              //   label: 'Open links',
              //   trailing:
              //       const Text('In app', style: TextStyle(color: Colors.grey)),
              //   onTap: () => context.push('/profile/settings'),
              // ),
              // _SettingsTile(
              //   label: 'Default sort',
              //   trailing:
              //       const Text('Manual', style: TextStyle(color: Colors.grey)),
              //   onTap: () => context.push('/profile/settings'),
              //   showDivider: false,
              // ),
            ],
          ),
        ),

        // ── Data ─────────────────────────────────────────────────────
        _SectionHeader(title: 'DATA'),
        _Card(
          child: Column(
            children: [
              _SettingsTile(
                label: 'Export data (JSON)',
                onTap: _dataBusy
                    ? null
                    : () => _handleExportData(context),
              ),
              _SettingsTile(
                label: 'Import data',
                onTap: _dataBusy
                    ? null
                    : () => _handleImportData(context),
              ),
              _SettingsTile(
                label: 'Clear all data',
                onTap: _dataBusy
                    ? null
                    : () => _confirmClearData(context),
                showDivider: false,
              ),
            ],
          ),
        ),

        // ── DayPass (free tier only) ──────────────────────────────────
        if (!isPremium) ...[
          _SectionHeader(title: 'ADS & DAYPASS'),
          _Card(child: _DayPassSettingsTile(theme: Theme.of(context))),
        ],

        // ── Support ───────────────────────────────────────────────────
        _SectionHeader(title: 'SUPPORT'),
        _Card(
          child: Column(
            children: [
              _SettingsTile(
                label: 'About LinkVault',
                onTap: () => context.push('/profile/about'),
              ),
              _SettingsTile(
                label: 'Help & feedback',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Help & feedback is under construction — check back soon.',
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                label: 'Privacy Policy',
                onTap: () => context.push('/profile/legal'),
              ),
              _SettingsTile(
                label: 'Terms of Service',
                onTap: () => context.push('/profile/legal'),
              ),
              _SettingsTile(
                label: 'Rate the app',
                onTap: () => _openPlayStoreForRating(context),
                showDivider: false,
              ),
            ],
          ),
        ),

        // Developer Tools — dev flavor only
        if (AppConfig.instance.isDev) ...[
          _SectionHeader(title: 'DEVELOPER'),
          _Card(
            child: _SettingsTile(
              label: '🔧 Debug Utilities',
              onTap: () => context.push('/profile/debug'),
              showDivider: false,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Sign out ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: Text(
              'Sign out',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _handleExportData(BuildContext context) async {
    if (_dataBusy) return;
    setState(() => _dataBusy = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final result = await ref.read(exportDataUseCaseProvider).execute();
    if (context.mounted) _dismissProgressIfOpen(context);
    if (mounted) setState(() => _dataBusy = false);

    if (!context.mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (filePath) {
        ref.invalidate(localVaultStorageUsageProvider);
        // ignore: deprecated_member_use
        Share.shareXFiles([XFile(filePath)]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported — choose where to save or share')),
        );
      },
    );
  }

  Future<void> _handleImportData(BuildContext context) async {
    if (_dataBusy) return;
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['curate', 'json'],
    );
    if (pick == null || pick.files.isEmpty) return;
    final filePath = pick.files.first.path;
    if (filePath == null || filePath.isEmpty) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Import backup?'),
        content: const Text(
          'Collections and links from the file will be merged into your library. '
          'Rows with the same ID are updated. Links that already exist in a folder '
          '(same URL) are skipped to avoid duplicates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _dataBusy = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final importResult =
        await ref.read(importDataUseCaseProvider).execute(filePath);
    if (context.mounted) _dismissProgressIfOpen(context);
    if (mounted) setState(() => _dataBusy = false);

    if (!context.mounted) return;
    importResult.fold(
      (failure) {
        showDialog<void>(
          context: context,
          useRootNavigator: true,
          builder: (ctx) => AlertDialog(
            title: const Text('Import failed'),
            content: Text(failure.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      (successResult) {
        final buf = StringBuffer()
          ..writeln(
            'Collections: ${successResult.collectionsCreated} new, '
            '${successResult.collectionsUpdated} updated'
            '${successResult.collectionsFailed > 0 ? ', ${successResult.collectionsFailed} failed' : ''}.',
          )
          ..writeln(
            'Links: ${successResult.itemsCreated} new, '
            '${successResult.itemsUpdated} updated, '
            '${successResult.itemsSkippedDuplicate} skipped (duplicate URL), '
            '${successResult.itemsSkippedOrphan} skipped (missing folder)'
            '${successResult.itemsFailed > 0 ? ', ${successResult.itemsFailed} failed' : ''}.',
          );
        showDialog<void>(
          context: context,
          useRootNavigator: true,
          builder: (ctx) => AlertDialog(
            title: const Text('Import complete'),
            content: SingleChildScrollView(child: Text(buf.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        ref.invalidate(collectionsListProvider);
        ref.invalidate(libraryRootCollectionProvider);
        ref.invalidate(localVaultStorageUsageProvider);
      },
    );
  }

  Future<void> _confirmClearData(BuildContext context) async {
    if (_dataBusy) return;
    final userId = ref.read(currentUserProvider)?.supabaseId;
    final isOnline = ref.read(isOnlineProvider);

    final goAhead = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all library data?'),
        content: Text(
          userId == null
              ? 'This removes all collections and links stored on this device.'
              : 'This removes all collections and links on this device '
                    'and in your cloud library for this account. '
                    'Your profile and sign-in are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (goAhead != true || !context.mounted) return;

    final confirmDestructive = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('This cannot be undone'),
        content: const Text(
          'All folders and saved links will be deleted. '
          'If you use cloud sync, your online library will be emptied too (when online).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmDestructive != true || !context.mounted) return;

    setState(() => _dataBusy = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final outcome = await ref.read(clearAllLibraryDataUseCaseProvider).call(
          userId: userId,
          isOnline: isOnline,
        );

    if (context.mounted) _dismissProgressIfOpen(context);
    if (mounted) setState(() => _dataBusy = false);

    ref.invalidate(collectionsListProvider);
    ref.invalidate(libraryRootCollectionProvider);
    ref.invalidate(syncCoordinatorProvider);
    ref.invalidate(localVaultStorageUsageProvider);

    if (!context.mounted) return;

    if (!outcome.localCleared && outcome.cloudErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(outcome.cloudErrorMessage!)),
      );
      return;
    }

    final cloudMsg = !outcome.cloudAttempted
        ? ''
        : outcome.cloudCleared
            ? ' Cloud library cleared.'
            : ' Cloud could not be fully cleared: ${outcome.cloudErrorMessage ?? 'unknown error'}.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome.localCleared
              ? 'Device library cleared.$cloudMsg'
              : 'Nothing was cleared.',
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }
}

// ── Reusable UI widgets ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
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

/// Shared profile section surface: consistent fill + rounded clips (no square ink/splash corners).
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Material(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
          child: child,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          enabled: onTap != null,
          title: Text(label, style: theme.textTheme.bodyMedium),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing!,
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          visualDensity: VisualDensity.compact,
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _ThemeValueText extends ConsumerWidget {
  const _ThemeValueText({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final themeState = widgetRef.watch(themeProvider);
    final label = switch (themeState.mode) {
      AppThemeMode.light => 'Light',
      AppThemeMode.dark => 'Dark',
      AppThemeMode.system => 'System',
    };
    return Text(label, style: const TextStyle(color: Colors.grey));
  }
}

// ── DayPass settings tile — status + short copy (detail on Day Pass screen) ──

class _DayPassSettingsTile extends ConsumerWidget {
  final ThemeData theme;
  const _DayPassSettingsTile({required this.theme});

  static String _titleFor(DayPassStatus s) => switch (s) {
        DayPassStatus.premium => 'Premium active',
        DayPassStatus.freeTrial => 'Free trial active',
        DayPassStatus.active => 'Daily Access Pass active',
        DayPassStatus.grace => 'Grace period',
        DayPassStatus.expired => 'Access paused',
      };

  static String _subtitleFor(DayPassStatus s) => switch (s) {
        DayPassStatus.premium =>
          'No ads. Full access to your library.',
        DayPassStatus.expired =>
          'Watch a short ad or upgrade to Premium to keep using the app.',
        DayPassStatus.grace =>
          'Limited access while offline or after an ad issue. Open Daily Access Pass when online.',
        DayPassStatus.freeTrial =>
          'No ads during your trial. After it ends, one ad per day can renew access. Details on Daily Access Pass.',
        DayPassStatus.active =>
          'Your pass is active. Open Daily Access Pass to renew early or see full status.',
      };

  static IconData _leadingIcon(DayPassStatus s) => switch (s) {
        DayPassStatus.premium => Icons.workspace_premium_outlined,
        DayPassStatus.freeTrial => Icons.auto_awesome_outlined,
        DayPassStatus.active => Icons.confirmation_number_outlined,
        DayPassStatus.grace => Icons.cloud_off_outlined,
        DayPassStatus.expired => Icons.pause_circle_outline,
      };

  static Color? _leadingIconColor(ThemeData theme, DayPassStatus s) {
    final cs = theme.colorScheme;
    return switch (s) {
      DayPassStatus.premium => cs.primary,
      DayPassStatus.freeTrial => cs.tertiary,
      DayPassStatus.active => cs.primary,
      DayPassStatus.grace => cs.onSurfaceVariant,
      DayPassStatus.expired => cs.error,
    };
  }

  static String _chipLabel(DayPassStatus s) => switch (s) {
        DayPassStatus.premium => 'Premium',
        DayPassStatus.freeTrial => 'Trial',
        DayPassStatus.active => 'Active',
        DayPassStatus.grace => 'Grace',
        DayPassStatus.expired => 'Paused',
      };

  static (Color fg, Color? bg) _chipColors(ThemeData theme, DayPassStatus s) {
    final cs = theme.colorScheme;
    return switch (s) {
      DayPassStatus.premium => (cs.onPrimaryContainer, cs.primaryContainer),
      DayPassStatus.freeTrial => (cs.onTertiaryContainer, cs.tertiaryContainer),
      DayPassStatus.active => (cs.onPrimaryContainer, cs.primaryContainer),
      DayPassStatus.grace => (cs.onSurfaceVariant, cs.surfaceContainerHighest),
      DayPassStatus.expired => (cs.onErrorContainer, cs.errorContainer),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateAsync = ref.watch(adGateProvider);

    return gateAsync.when(
      loading: () => ListTile(
        leading: const Icon(Icons.confirmation_number_outlined),
        title: Text('Daily Access Pass', style: theme.textTheme.bodyMedium),
        subtitle: const Text('Checking your access status…'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => ListTile(
        leading: Icon(
          Icons.confirmation_number_outlined,
          color: theme.colorScheme.error,
        ),
        title: Text('Daily Access Pass', style: theme.textTheme.bodyMedium),
        subtitle: const Text(
          'Could not verify access. Open Daily Access Pass to retry or continue offline if eligible.',
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: FilledButton.tonal(
          onPressed: () => context.push('/daypass'),
          child: const Text('Open'),
        ),
        onTap: () => context.push('/daypass'),
      ),
      data: (status) {
        final iconColor = _leadingIconColor(theme, status);
        final chip = _chipColors(theme, status);
        return ListTile(
          
          onTap: () => context.push('/daypass'),
          leading: Icon(
            _leadingIcon(status),
            color: iconColor,
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _titleFor(status),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  _chipLabel(status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: chip.$1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                backgroundColor: chip.$2,
                side: BorderSide.none,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _subtitleFor(status),
              style: theme.textTheme.bodySmall,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        );
      },
    );
  }
}
