import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_notifier.dart';

/// Entry point for unauthenticated users.
/// Layout matches the wireframe: logo → tagline → Sign up / Sign in →
/// divider → Continue as Guest → terms note.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final busy = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── Logo + brand ───────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.collections_bookmark_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'LinkVault',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save links. Find them.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),

              const Spacer(flex: 4),

              // ── Primary CTA: Sign up ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: busy
                      ? null
                      : () => context.push(
                            '/auth/email',
                            extra: AppOtpType.signup,
                          ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Secondary CTA: Sign in ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => context.push(
                            '/auth/email',
                            extra: AppOtpType.magiclink,
                          ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: cs.primary, width: 1.5),
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Divider ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: cs.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: cs.outlineVariant)),
                ],
              ),
              const SizedBox(height: 20),

              // ── Guest ─────────────────────────────────────────────────
              GestureDetector(
                onTap: busy
                    ? null
                    : () async {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .continueAsGuest();
                        if (context.mounted) context.go('/');
                      },
                child: Text(
                  'Continue as Guest →',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (busy) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],

              const Spacer(flex: 2),

              // ── Terms ─────────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms',
                      style: TextStyle(
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: cs.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push('/profile/legal'),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy',
                      style: TextStyle(
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: cs.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push('/profile/legal'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
