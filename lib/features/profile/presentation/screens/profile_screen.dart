import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/monetization/presentation/providers/ad_gate_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
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
        title: const Text('Profile'),
      ),
      body: profileState.when(
        data: (state) {
          if (state.isLoading) {
            return _buildSettingUpProfileState(context);
          }

          final profile = state.profile;
          if (profile == null) {
            return _buildProfileRecoveryState(
              context,
              ref,
              message: state.errorMessage,
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              const CloudDowngradeCard(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildHeader(context, profile, theme, isPremium),
                    const SizedBox(height: 32),
                    _buildSettingsSection(context, ref, theme),
                    const SizedBox(height: 32),
                    _buildSignOutButton(context, ref, theme),
                  ],
                ),
              ),
            ],
          );
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

  Widget _buildGuestPrompt(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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

  Widget _buildHeader(
      BuildContext context, dynamic profile, ThemeData theme, bool isPremium) {
    final cs = theme.colorScheme;
    final username = (profile.username as String?) ?? '';
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl)
              : null,
          child: profile.avatarUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 16),
        Text(profile.displayName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (username.isNotEmpty)
          Text('@$username',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
        Consumer(
          builder: (context, ref, _) {
            final email = ref.watch(currentUserProvider)?.email;
            if (email == null || email.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                email,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // ── Premium badge ──────────────────────────────────────────────────
        if (isPremium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'LinkVault Premium',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          TextButton.icon(
            onPressed: () => context.push('/paywall'),
            icon: const Icon(Icons.workspace_premium_rounded,
                size: 16, color: Colors.grey),
            label: Text(
              'Upgrade to Premium',
              style: theme.textTheme.labelMedium?.copyWith(color: cs.primary),
            ),
          ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(profile.bio!,
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            context.push('/profile/edit');
          },
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 24),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> tiles) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color:
          Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: ListTile.divideTiles(
          context: context,
          tiles: tiles,
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(100),
        ).toList(),
      ),
    );
  }

  Widget _buildDayPassTile(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return _buildSettingsGroup(context, [
      _DayPassSettingsTile(theme: theme),
    ]);
  }

  Widget _buildSettingsSection(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    final curUser = ref.watch(currentUserProvider);
    final isPremium = curUser?.isPremium ?? false;
    final themeState = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account & Subscription', theme),
        _buildSettingsGroup(context, [
          ListTile(
            leading: const Icon(Icons.star_rounded),
            title: const Text('Manage Subscription'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isPremium ? 'Premium' : 'Free Tier',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey)),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () => context.push('/paywall'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Appearance'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  switch (themeState.mode) {
                    AppThemeMode.light => 'Light',
                    AppThemeMode.dark => 'Dark',
                    AppThemeMode.system => 'System',
                  },
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () => _showThemePicker(context, ref, themeState.mode),
          ),
        ]),
        if (!isPremium) ...[
          _buildSectionHeader('Ads & DayPass', theme),
          _buildDayPassTile(context, ref, theme),
        ],
        // Notifications & Privacy — hidden until Sprint 10 social features ship
        if (AppConfig.instance.isDev) ...[
          _buildSectionHeader('Notifications & Privacy', theme),
          _buildSettingsGroup(context, [
            ListTile(
              leading: const Icon(Icons.notifications_none_rounded),
              title: const Text('Push Notifications'),
              trailing: Switch(value: true, onChanged: (val) {}),
            ),
            ListTile(
              leading: const Icon(Icons.public_rounded),
              title: const Text('Public Profile Visibility'),
              trailing: Switch(value: false, onChanged: (val) {}),
            ),
          ]),
        ],
        _buildSectionHeader('Support & Legal', theme),
        _buildSettingsGroup(context, [
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help & Feedback'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help portal opening soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Privacy Policy & Terms'),
            trailing: const Icon(Icons.open_in_new_rounded, color: Colors.grey),
            onTap: () {
              context.push('/profile/legal');
            },
          ),
        ]),
        _buildSectionHeader('Data Management', theme),
        _buildSettingsGroup(context, [
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Backup offline collections locally'),
            trailing: const Icon(Icons.ios_share_rounded, color: Colors.grey),
            onTap: () => _handleExportData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a backup file'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _handleImportData(context, ref),
          ),
        ]),
        // Developer Tools — always visible in Dev, hidden in Production
        if (AppConfig.instance.isDev) ...[
          _buildSectionHeader('Developer Tools', theme),
          _buildSettingsGroup(context, [
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('🔧 Debug Utilities'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => context.push('/profile/debug'),
            ),
          ]),
        ],
        const SizedBox(height: 32),
        Card(
          color: Colors.red.withAlpha(20),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.withAlpha(100)),
          ),
          child: ListTile(
            leading:
                const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Account',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be immediately wiped.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ref
                            .read(profileNotifierProvider.notifier)
                            .deleteAccount();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete Forever'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, AppThemeMode current) {
    final options = [
      (AppThemeMode.system, Icons.brightness_auto_rounded, 'System'),
      (AppThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (AppThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
    ];
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 4, top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Appearance',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                ),
                ...options.map(
                  (opt) => ListTile(
                    leading: Icon(opt.$2,
                        color: current == opt.$1
                            ? cs.primary
                            : cs.onSurfaceVariant),
                    title: Text(opt.$3),
                    trailing: current == opt.$1
                        ? Icon(Icons.check_rounded, color: cs.primary)
                        : null,
                    onTap: () {
                      ref.read(themeProvider.notifier).setMode(opt.$1);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignOutButton(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () async {
          await ref.read(authRepositoryProvider).signOut();
          if (context.mounted) {
            context.go('/auth/welcome');
          }
        },
      ),
    );
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (filePath) {
        if (context.mounted) {
          Share.shareXFiles([XFile(filePath)]);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Data exported successfully')),
          );
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;
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
                  child: const Text('OK'),
                ),
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
                '${successResult.itemsImported} items imported.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

// ── DayPass settings tile — owns its own countdown timer ──────────────────────

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
  bool _loading = false;

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
    setState(() {
      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gateAsync = ref.watch(adGateProvider);
    final status = gateAsync.valueOrNull;
    final cs = widget.theme.colorScheme;

    final (statusLabel, statusColor, showWatchButton) = switch (status) {
      DayPassStatus.freeTrial => ('Free Trial Active', Colors.green, false),
      DayPassStatus.active => ('Active', Colors.green, false),
      DayPassStatus.grace => ('Grace Period', Colors.orange, false),
      DayPassStatus.expired => ('Expired – Watch Ad', cs.error, true),
      DayPassStatus.premium => ('Premium', Colors.amber, false),
      null => ('Checking…', Colors.grey, false),
    };

    // Build the subtitle: countdown when active, label otherwise
    Widget subtitle;
    if (status == DayPassStatus.active && _remaining > Duration.zero) {
      final h = _remaining.inHours;
      final m = _remaining.inMinutes.remainder(60);
      final s = _remaining.inSeconds.remainder(60);
      final timeStr = h > 0
          ? '${h}h ${m.toString().padLeft(2, '0')}m remaining'
          : '${m}m ${s.toString().padLeft(2, '0')}s remaining';
      subtitle = Text(timeStr,
          style: TextStyle(
              color: statusColor, fontWeight: FontWeight.w600, fontSize: 12));
    } else {
      subtitle = Text(statusLabel,
          style: TextStyle(
              color: statusColor, fontWeight: FontWeight.w600, fontSize: 12));
    }

    return ListTile(
      onTap: () => context.push('/daypass'),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child:
            Icon(Icons.confirmation_num_rounded, size: 20, color: statusColor),
      ),
      title: const Text('Daily Access Pass'),
      subtitle: subtitle,
      trailing: gateAsync.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : showWatchButton
              ? FilledButton.tonal(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await ref
                              .read(adGateProvider.notifier)
                              .watchAdForAccess();
                          await _refresh();
                          if (mounted) setState(() => _loading = false);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Watch Ad',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                )
              : const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
