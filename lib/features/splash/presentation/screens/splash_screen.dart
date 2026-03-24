import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// The first screen shown on app launch.
///
/// Responsibilities:
/// 1. Wait for [authStateProvider] to resolve (Supabase session restore)
/// 2. Set install date for DayPass trial (idempotent — runs once ever)
/// 3. Navigate based on onboarding status and auth/guest state
///
/// Note: GoRouter redirect guard handles most routing logic.
/// Splash is responsible for the initial auth resolution delay.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Minimum splash display time
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted || _hasNavigated) return;

    // Record install date for DayPass 3-day trial (idempotent)
    final settings = ref.read(appSettingsRepositoryProvider);
    await settings.setInstallDateIfNotSet();

    // Wait for Supabase to restore session from storage
    final authAsync = ref.read(authStateProvider);
    if (authAsync.isLoading) {
      // Auth is still resolving — listen and navigate when ready
      return; // _authListener in build() will navigate
    }

    _navigate();
  }

  void _navigate() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    // GoRouter redirect guard handles the actual routing decision
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state resolution to trigger navigation
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      if (!next.isLoading && !_hasNavigated) {
        _navigate();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.appLogoReference,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
