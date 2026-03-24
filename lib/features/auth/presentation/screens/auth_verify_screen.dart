import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'auth_email_screen.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_providers.dart';

class AuthVerifyScreen extends ConsumerStatefulWidget {
  final AuthVerifyScreenParams params;

  const AuthVerifyScreen({
    super.key,
    required this.params,
  });

  @override
  ConsumerState<AuthVerifyScreen> createState() => _AuthVerifyScreenState();
}

class _AuthVerifyScreenState extends ConsumerState<AuthVerifyScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify(String otp) async {
    await ref.read(authNotifierProvider.notifier).verifyOTP(
          email: widget.params.email,
          otp: otp,
          type: widget.params.type,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    ref.listen(authNotifierProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null && !user.isGuest && context.mounted) {
        context.go('/');
      }
    });

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: theme.textTheme.headlineMedium,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter the 6-digit code sent to:',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                widget.params.email,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'After verification, we will set up your LinkVault profile if this is your first login here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                ),
                onCompleted: _verify,
                enabled: !authState.isLoading,
                autofocus: true,
              ),
              const SizedBox(height: 48),
              if (authState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref.read(authNotifierProvider.notifier).signInWithOTP(
                            email: widget.params.email, type: widget.params.type);
                        if (!mounted) return;
                        final hasError =
                            ref.read(authNotifierProvider).errorMessage != null;
                        if (!hasError) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('A new code has been sent')),
                          );
                        }
                      },
                      child: const Text('Resend Code'),
                    ),
                    TextButton(
                      onPressed: () => context.go(
                        '/auth/email',
                        extra: widget.params.type,
                      ),
                      child: const Text('Wrong email? Change it'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
