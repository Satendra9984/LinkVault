import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/color_palette.dart';
import '../../application/cloud_migration_service.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../items/presentation/providers/items_providers.dart';

final migrationServiceProvider = Provider<CloudMigrationService>((ref) {
  return CloudMigrationService(
    supabase: Supabase.instance.client,
    appDatabase: ref.watch(appDatabaseProvider),
    localCollectionsRepo: ref.watch(collectionsRepositoryProvider),
    localItemsRepo: ref.watch(itemsRepositoryProvider),
  );
});

class MigrationScreen extends ConsumerStatefulWidget {
  const MigrationScreen({super.key});

  @override
  ConsumerState<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends ConsumerState<MigrationScreen> {
  double _progress = 0.0;
  String _status = 'Initializing cloud sync...';
  bool _isError = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndStart();
    });
  }

  void _checkAuthAndStart() {
    final user = Supabase.instance.client.auth.currentUser;
    // If the user hasn't actually logged in (they skipped auth natively as a guest)
    if (user == null) {
      setState(() {
        _isGuest = true;
        _status =
            'Please attach an email to your account to securely back up your Premium data to the cloud.';
      });
      return;
    }
    _startMigration();
  }

  Future<void> _startMigration() async {
    final service = ref.read(migrationServiceProvider);

    final result = await service.migrateToCloud(
      onProgress: (progress, step) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _status = step;
          });
        }
      },
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isError = true;
          _status = 'Sync Failed: ${failure.message}';
        });
      },
      (_) {
        // Force Riverpod to refresh the entire graph and swap the Repo Providers
        ref.invalidate(collectionsListProvider);
        // Go to Home
        context.go('/splash');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.premiumDark : AppColors.background;
    final text = isDark ? AppColors.premiumTextLight : AppColors.text;
    final accent = AppColors.premiumGold;

    return PopScope(
      canPop: false, // Blocking screen
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isError ? Icons.error_outline : Icons.cloud_sync,
                  size: 64,
                  color: _isError ? AppColors.error : accent,
                ),
                const SizedBox(height: 32),
                Text(
                  _isError ? 'Migration Failed' : 'Upgrading your account...',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Fraunces',
                    color: text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_isGuest) ...[
                  Text(
                    _status,
                    style:
                        TextStyle(color: text.withOpacity(0.7), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/auth/signup').then((_) {
                        // When they return from sign up, theoretically they are no longer a guest.
                        setState(() {
                          _isGuest = false;
                        });
                        _checkAuthAndStart();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: AppColors.premiumDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('LINK ACCOUNT'),
                  ),
                ] else if (_isError) ...[
                  Text(
                    _status,
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isError = false;
                        _progress = 0.0;
                      });
                      _startMigration();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: AppColors.premiumDark,
                    ),
                    child: const Text('RETRY SYNC'),
                  ),
                ] else ...[
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: text.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    style:
                        TextStyle(color: text.withOpacity(0.7), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
