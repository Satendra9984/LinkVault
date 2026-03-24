import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/debug_providers.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  bool _isLoading = false;

  Future<void> _runAction(
      Future<void> Function() action, String successMessage) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ $successMessage')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
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
                _buildSectionHeader('Data Generation'),
                ListTile(
                  leading: const Icon(Icons.folder_shared),
                  title: const Text('Generate 5 Mock Collections'),
                  onTap: () => _runAction(
                    () => tools.generateMockCollections(5),
                    'Generated 5 mock collections',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Generate 20 Mock Items'),
                  subtitle: const Text('Requires at least one collection'),
                  onTap: () => _runAction(
                    () => tools.generateMockItems(20),
                    'Generated 20 mock items',
                  ),
                ),
                const Divider(),
                _buildSectionHeader('State Overrides'),
                ListTile(
                  leading: const Icon(Icons.timer_off),
                  title: const Text('Reset Ad DayPass Timer'),
                  subtitle:
                      const Text('Simulates an expired free trial & Ad pass'),
                  onTap: () => _runAction(
                    tools.resetAdTimer,
                    'Ad timer reset successfully',
                  ),
                ),
                const Divider(),
                _buildSectionHeader('Data Management (DANGER)'),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear Local Database',
                      style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Wipes objectbox collections and items'),
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
