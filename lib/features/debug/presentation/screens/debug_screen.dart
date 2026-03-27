import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/mock_dataset_profile.dart';
import '../providers/debug_providers.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  bool _isLoading = false;

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OK $successMessage')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tools = ref.read(debugToolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Utilities'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Mock dataset (schema-safe)'),
                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: const Text('Generate mock dataset (Small)'),
                  subtitle: const Text(
                    '8 folders under Library + 40 URLs; depth 1-4 chain + layouts',
                  ),
                  onTap: () => _runAction(
                    () => tools.regenerateMockDataset(MockDatasetProfile.small),
                    'Small mock dataset ready',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('Generate mock dataset (Medium)'),
                  subtitle: const Text('24 folders + 240 URLs'),
                  onTap: () => _runAction(
                    () => tools.regenerateMockDataset(MockDatasetProfile.medium),
                    'Medium mock dataset ready',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda),
                  title: const Text('Generate mock dataset (Large)'),
                  subtitle: const Text('60 folders + 1200 URLs (stress)'),
                  onTap: () => _runAction(
                    () => tools.regenerateMockDataset(MockDatasetProfile.large),
                    'Large mock dataset ready',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Generate mock dataset (quota boundary)'),
                  subtitle: const Text(
                    '50 folders + 1200 URLs (guest folder cap)',
                  ),
                  onTap: () => _runAction(
                    () => tools.regenerateMockDataset(
                      MockDatasetProfile.quotaBoundaryGuest,
                    ),
                    'Quota-boundary mock dataset ready',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('Cleanup generated mock data only'),
                  subtitle: const Text(
                    'Removes titles tagged [DEBUG_MOCK]; keeps Library root',
                  ),
                  onTap: () => _runAction(
                    tools.deleteGeneratedMocksOnly,
                    'Mock cleanup finished',
                  ),
                ),
                const Divider(),
                _buildSectionHeader('State Overrides'),
                ListTile(
                  leading: const Icon(Icons.timer_off),
                  title: const Text('Reset Ad DayPass Timer'),
                  subtitle: const Text(
                    'Simulates an expired free trial and Ad pass',
                  ),
                  onTap: () => _runAction(
                    tools.resetAdTimer,
                    'Ad timer reset successfully',
                  ),
                ),
                const Divider(),
                _buildSectionHeader('Data Management (DANGER)'),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Clear Local Database',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Wipes ObjectBox collections and items'),
                  onTap: () => _runAction(
                    tools.clearLocalData,
                    'Local database cleared',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
