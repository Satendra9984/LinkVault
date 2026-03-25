import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_assets.dart';

/// Simple informational screen for `/profile/about`.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<String> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: FutureBuilder<String>(
        future: _loadVersion(),
        builder: (context, snapshot) {
          final versionText =
              snapshot.hasData ? 'Version ${snapshot.data}' : 'Loading…';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      AppAssets.appLogoReference,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LinkVault',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      versionText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/profile/legal'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/profile/legal'),
                    ),
                  ],
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Help & Feedback'),
                  subtitle:
                      const Text('Feedback portal opening soon.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help portal opening soon!')),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

