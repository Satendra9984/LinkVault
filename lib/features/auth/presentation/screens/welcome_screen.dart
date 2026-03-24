import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_notifier.dart';

/// Entry point for unauthenticated users.
/// Options: Sign up, Sign in, Continue as Guest.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo / Brand ───────────────────────────────────────────
              Icon(
                Icons.collections_bookmark_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'LinkVault',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save links. Organize collections.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(flex: 3),

              // ── Buttons ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () =>
                          context.push('/auth/email', extra: AppOtpType.signup),
                  child: const Text('Sign up'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => context.push('/auth/email',
                          extra: AppOtpType.magiclink),
                  child: const Text('Sign in'),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .continueAsGuest();
                        if (context.mounted) context.go('/');
                      },
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),

              if (authState.isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
