import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'auth_email_screen.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_providers.dart';
import '../../../../core/providers/core_providers.dart';

class AuthVerifyScreen extends ConsumerStatefulWidget {
  final AuthVerifyScreenParams params;

  const AuthVerifyScreen({super.key, required this.params});

  @override
  ConsumerState<AuthVerifyScreen> createState() => _AuthVerifyScreenState();
}

class _AuthVerifyScreenState extends ConsumerState<AuthVerifyScreen> {
  final _otpController = TextEditingController();
  bool _wasGuestBeforeVerify = false;

  // Resend countdown (30 seconds)
  static const int _cooldownSeconds = 30;
  int _resendSecondsLeft = _cooldownSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSecondsLeft = _cooldownSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendSecondsLeft > 0) {
          _resendSecondsLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> _verify(String otp) async {
    _wasGuestBeforeVerify =
        await ref.read(appSettingsRepositoryProvider).isGuestMode();
    await ref.read(authNotifierProvider.notifier).verifyOTP(
          email: widget.params.email,
          otp: otp,
          type: widget.params.type,
        );
  }

  Future<void> _resendCode() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(authNotifierProvider.notifier).signInWithOTP(
          email: widget.params.email,
          type: widget.params.type,
        );
    if (!mounted) return;
    final hasError = ref.read(authNotifierProvider).errorMessage != null;
    if (!hasError) {
      messenger.showSnackBar(
        const SnackBar(content: Text('A new code has been sent')),
      );
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final busy = authState.isLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: cs.error,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
        // Clear the pin on error so user can retry
        _otpController.clear();
      }
    });

    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null && !user.isGuest && context.mounted) {
        if (_wasGuestBeforeVerify) {
          context.go('/migration');
        } else {
          context.go('/');
        }
      }
    });

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontFamily: 'monospace',
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Mail icon ──────────────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mail_outline_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),

              // ── Headline ───────────────────────────────────────────────
              Text(
                'Check your inbox',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                    TextSpan(
                      text: widget.params.email,
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // ── Pinput ────────────────────────────────────────────────
              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: cs.primary, width: 2),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: cs.error, width: 2),
                  ),
                ),
                onCompleted: busy ? null : _verify,
                enabled: !busy,
                autofocus: true,
              ),

              const SizedBox(height: 32),

              // ── Verifying / Resend / Change email ──────────────────────
              if (busy)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Verifying…',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Resend code with countdown
                    GestureDetector(
                      onTap: _resendSecondsLeft == 0 ? _resendCode : null,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: "Didn't receive it?  ",
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                            TextSpan(
                              text: _resendSecondsLeft > 0
                                  ? 'Resend code ($_resendSecondsLeft s)'
                                  : 'Resend code',
                              style: TextStyle(
                                color: _resendSecondsLeft > 0
                                    ? cs.onSurfaceVariant
                                    : cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.go(
                        '/auth/email',
                        extra: widget.params.type,
                      ),
                      child: Text(
                        'Wrong email? Change it',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
