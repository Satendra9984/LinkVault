import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/models/auth_settings_model.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// App Settings at `/profile/settings` — appearance, sync (premium), notifications.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowAsync = ref.watch(authSettingsRowStreamProvider);

    return rowAsync.when(
      data: (row) => _SettingsBody(settings: row),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: const Text('Settings'),
        ),
        body: Center(child: Text('Could not load settings: $e')),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});

  final AuthSettingsModel settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final themeState = ref.watch(themeProvider);
    final repo = ref.watch(appSettingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: 'APPEARANCE'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                _SegmentedThemePicker(current: themeState.mode),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          _SectionHeader(title: 'SYNC (PREMIUM ONLY)'),
          SwitchListTile(
            title: const Text('Auto-sync'),
            subtitle:
                const Text('When online, keep cloud in sync with your library'),
            value: settings.autoSyncEnabled,
            onChanged: isPremium ? (v) => repo.setAutoSyncEnabled(v) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          SwitchListTile(
            title: const Text('Sync on Wi‑Fi only'),
            subtitle: const Text('Reduce mobile data use for background sync'),
            value: settings.syncWifiOnly,
            onChanged: isPremium ? (v) => repo.setSyncWifiOnly(v) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          if (!isPremium)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Upgrade to Premium to enable cloud sync options.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const Divider(indent: 16, endIndent: 16),
          _SectionHeader(title: 'NOTIFICATIONS'),
          SwitchListTile(
            title: const Text('New link saved'),
            subtitle: const Text('Reserved for a future release'),
            value: settings.notifyLinkSaved,
            onChanged: (v) => repo.setNotifyLinkSaved(v),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          SwitchListTile(
            title: const Text('Sync complete'),
            subtitle: const Text('Reserved for a future release'),
            value: settings.notifySyncComplete,
            onChanged: (v) => repo.setNotifySyncComplete(v),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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

class _SegmentedThemePicker extends ConsumerWidget {
  const _SegmentedThemePicker({required this.current});

  final AppThemeMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final options = [
      (AppThemeMode.light, 'Light', Icons.light_mode_rounded),
      (AppThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
      (AppThemeMode.system, 'System', Icons.brightness_auto_rounded),
    ];

    return SegmentedButton<AppThemeMode>(
      showSelectedIcon: false,
      segments: options.map((o) {
        return ButtonSegment<AppThemeMode>(
          value: o.$1,
          icon: Icon(o.$3, size: 16),
          label: Text(o.$2),
        );
      }).toList(),
      selected: {current},
      onSelectionChanged: (sel) =>
          ref.read(themeProvider.notifier).setMode(sel.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primary.withValues(alpha: 0.15);
          }
          return null;
        }),
      ),
    );
  }
}
