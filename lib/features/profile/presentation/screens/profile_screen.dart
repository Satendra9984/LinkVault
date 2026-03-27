import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/profile_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../monetization/presentation/providers/ad_gate_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../monetization/presentation/widgets/cloud_downgrade_card.dart';
import '../../../../core/config/app_config.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/auth/welcome');
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
              Text('Create an account',
                  style: theme.textTheme.headlineSmall),
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

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.isPremium});

  final dynamic profile;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final username = (profile.username as String?) ?? '';

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const CloudDowngradeCard(),

        // ── User card ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl as String)
                      : null,
                  child: profile.avatarUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
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

        // ── Storage (placeholder) ─────────────────────────────────────
        _SectionHeader(title: 'STORAGE'),
        _Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.05,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Local storage in use',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
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
              ),
              _SettingsTile(
                label: 'Open links',
                trailing: const Text('In app',
                    style: TextStyle(color: Colors.grey)),
                onTap: () => context.push('/profile/settings'),
              ),
              _SettingsTile(
                label: 'Default sort',
                trailing:
                    const Text('Manual', style: TextStyle(color: Colors.grey)),
                onTap: () => context.push('/profile/settings'),
                showDivider: false,
              ),
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
                onTap: () => _handleExportData(context, ref),
              ),
              _SettingsTile(
                label: 'Import data',
                onTap: () => _handleImportData(context, ref),
              ),
              _SettingsTile(
                label: 'Clear all data',
                onTap: () => _confirmClearData(context, ref),
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
                label: 'Privacy Policy',
                onTap: () => context.push('/profile/legal'),
              ),
              _SettingsTile(
                label: 'Terms of Service',
                onTap: () => context.push('/profile/legal'),
              ),
              _SettingsTile(
                label: 'Rate the app',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening store page soon!')),
                ),
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
          child: GestureDetector(
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/auth/welcome');
            },
            child: Text(
              'Sign out',
              textAlign: TextAlign.center,
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

  void _handleExportData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final result = await ref.read(exportDataUseCaseProvider).execute();
    if (context.mounted) Navigator.of(context).pop();
    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      (filePath) {
        if (context.mounted) {
          // ignore: deprecated_member_use
      Share.shareXFiles([XFile(filePath)]);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Data exported successfully')));
        }
      },
    );
  }

  void _handleImportData(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['curate', 'json'],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.first.path!;
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import Data?'),
        content: const Text(
          'This will append collections and items from the backup file. '
          'Existing items will be preserved safely.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Import')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final importResult =
        await ref.read(importDataUseCaseProvider).execute(filePath);
    if (context.mounted) Navigator.of(context).pop();
    importResult.fold(
      (failure) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Import Failed'),
              content: Text(failure.message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'))
              ],
            ),
          );
        }
      },
      (successResult) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('✅ Import Complete'),
              content: Text(
                  '${successResult.collectionsImported} collections and '
                  '${successResult.itemsImported} items imported.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'))
              ],
            ),
          );
        }
      },
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will delete all local collections and links. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
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

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
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
        if (showDivider)
          const Divider(height: 1, indent: 16, endIndent: 16),
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

// ── DayPass settings tile — owns its own countdown timer ─────────────────────

class _DayPassSettingsTile extends ConsumerStatefulWidget {
  final ThemeData theme;
  const _DayPassSettingsTile({required this.theme});

  @override
  ConsumerState<_DayPassSettingsTile> createState() =>
      _DayPassSettingsTileState();
}

class _DayPassSettingsTileState extends ConsumerState<_DayPassSettingsTile> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  final bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final d = await ref.read(adGateProvider.notifier).remainingDuration();
    if (mounted) setState(() => _remaining = d);
  }

  void _tick() {
    if (!mounted) return;
    if (_remaining.inSeconds > 0) {
      setState(() => _remaining -= const Duration(seconds: 1));
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final hasPass = _remaining.inSeconds > 0;
    return ListTile(
      leading: const Icon(Icons.confirmation_number_outlined),
      title: Text(hasPass ? 'DayPass active' : 'DayPass inactive',
          style: widget.theme.textTheme.bodyMedium),
      subtitle: Text(
        hasPass
            ? 'Expires in ${_fmt(_remaining)}'
            : 'Watch an ad to unlock full access today',
        style: widget.theme.textTheme.bodySmall,
      ),
      trailing: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FilledButton.tonal(
              onPressed: () => context.push('/ad-gate'),
              child: const Text('Get pass'),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
