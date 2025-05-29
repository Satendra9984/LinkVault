import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/presentation/blocs/email_verification_bloc/email_verification_bloc.dart';
import 'package:link_vault/src/common/repository_layer/enums/snakbar_type.dart';

class EmailVerifiedPage extends StatefulWidget {
  const EmailVerifiedPage({
    super.key,
    this.authToken,
  });

  final String? authToken;

  @override
  State<EmailVerifiedPage> createState() => _EmailVerifiedPageState();
}

class _EmailVerifiedPageState extends State<EmailVerifiedPage> {
  @override
  void initState() {
    if (widget.authToken != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          context.read<EmailVerificationBloc>().add(
                VerifyEmailToken(
                  authCode: widget.authToken!,
                ),
              );
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final colorScheme = appTheme.colorScheme;
    final textTheme = appTheme.textTheme;
    return Scaffold(
      body: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
        listener: (context, state) {
          if (state is EmailVerificationSuccess) {
            // Show success message and navigate to login after delay
            showSnackbar(
              context: context,
              title: 'Email Verified Successfully.',
              subtitle:
                  'We have successfully verified your email address. Login to proceed.',
              snackbarType: SnackbarType.success,
            );

            Future.delayed(
              const Duration(seconds: 2),
              () {
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              },
            );
          } else if (state is EmailVerificationError) {
            // Navigate to error page
            // context.go(
            //   '${RoutePaths.emailVerificationError}?error=${Uri.encodeComponent(state.message)}',
            // );
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is EmailVerificationLoading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    const Text('Verifying your email...'),
                  ] else if (state is EmailVerificationSuccess) ...[
                    Icon(
                      Icons.check_circle,
                      color: ColourPallette.success,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Email Verified!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your email has been successfully verified.\nRedirecting to login...',
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(
                      Icons.error_outline,
                      color: ColourPallette.warning,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text('Verifying...'),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
