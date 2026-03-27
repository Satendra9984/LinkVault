import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// App Settings screen at `/profile/settings`.
/// Groups: Appearance · Links · Collections · Sync (premium) · Notifications.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Appearance ──────────────────────────────────────────────────
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

          // ── Links ────────────────────────────────────────────────────────
          _SectionHeader(title: 'LINKS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open links by default', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                _SegmentedOptionPicker(
                  options: const ['In app', 'Browser'],
                  selectedIndex: 0,
                  onChanged: (_) {}, // TODO: persist to settings repo
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Show link previews'),
            subtitle: const Text('Thumbnails on link cards'),
            value: true,
            onChanged: (_) {}, // TODO: persist
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          SwitchListTile(
            title: const Text('Show favicons'),
            value: true,
            onChanged: (_) {},
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const Divider(indent: 16, endIndent: 16),

          // ── Collections ──────────────────────────────────────────────────
          _SectionHeader(title: 'COLLECTIONS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default folders layout',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                _SegmentedOptionPicker(
                  options: const ['Grid', 'List', 'Compact'],
                  selectedIndex: 0,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                Text('Default links layout', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                _SegmentedOptionPicker(
                  options: const ['List', 'Cards', 'Icons'],
                  selectedIndex: 0,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          // ── Sync ─────────────────────────────────────────────────────────
          _SectionHeader(title: 'SYNC (PREMIUM ONLY)'),
          SwitchListTile(
            title: const Text('Auto-sync'),
            value: isPremium,
            onChanged: isPremium ? (_) {} : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          SwitchListTile(
            title: const Text('Sync on WiFi only'),
            value: false,
            onChanged: isPremium ? (_) {} : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          if (!isPremium)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Upgrade to Premium to enable cloud sync.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const Divider(indent: 16, endIndent: 16),

          // ── Notifications ────────────────────────────────────────────────
          _SectionHeader(title: 'NOTIFICATIONS'),
          SwitchListTile(
            title: const Text('New link saved'),
            value: false,
            onChanged: (_) {},
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          SwitchListTile(
            title: const Text('Sync complete'),
            value: false,
            onChanged: (_) {},
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Reusable helpers ─────────────────────────────────────────────────────────

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

class _SegmentedOptionPicker extends StatelessWidget {
  const _SegmentedOptionPicker({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: options.indexed.map((e) {
        return ButtonSegment<int>(
          value: e.$1,
          label: Text(e.$2),
        );
      }).toList(),
      selected: {selectedIndex},
      onSelectionChanged: (sel) => onChanged(sel.first),
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
