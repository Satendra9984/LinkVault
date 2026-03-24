import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_providers.dart';

class AuthEmailScreenParams {
  final AppOtpType initialType;
  const AuthEmailScreenParams({required this.initialType});
}

class AuthVerifyScreenParams {
  final String email;
  final AppOtpType type;
  const AuthVerifyScreenParams({required this.email, required this.type});
}

class AuthEmailScreen extends ConsumerStatefulWidget {
  final AuthEmailScreenParams params;

  const AuthEmailScreen({super.key, required this.params});

  @override
  ConsumerState<AuthEmailScreen> createState() => _AuthEmailScreenState();
}

class _AuthEmailScreenState extends ConsumerState<AuthEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AppOtpType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.params.initialType;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final notifier = ref.read(authNotifierProvider.notifier);

    await notifier.signInWithOTP(email: email, type: _currentType);

    if (ref.read(authNotifierProvider).otpSent) {
      if (!mounted) return;
      context.go(
        '/auth/verify',
        extra: AuthVerifyScreenParams(email: email, type: _currentType),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentType == AppOtpType.signup ? 'Create Account' : 'Sign In',
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  _currentType == AppOtpType.signup
                      ? 'Enter your email address to create a new account.'
                      : 'Enter your email address to receive a secure login code.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'If you used Curate before, sign in with the same email. We will set up your LinkVault profile automatically.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentType = _currentType == AppOtpType.signup
                          ? AppOtpType.magiclink
                          : AppOtpType.signup;
                    });
                  },
                  child: Text(
                    _currentType == AppOtpType.signup
                        ? 'Already have an account? Sign In'
                        : 'Don\'t have an account? Sign Up',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your local data stays on this device. We will never overwrite local data silently.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
