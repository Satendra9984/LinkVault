// [UI] https://dribbble.com/shots/16519810-Xigman-Reset-Password

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/presentation/blocs/email_verification_bloc/email_verification_bloc.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    const gap = 16.0;
    final size = MediaQuery.of(context).size;

    final appTheme = Theme.of(context);
    final colorScheme = appTheme.colorScheme;
    final textTheme = appTheme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // appBar: AppBar(
      //   backgroundColor: colorScheme.surface,
      //   foregroundColor: colorScheme.onSurface,
      // ),
      body: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
        listener: (context, state) {
          if (state is EmailVerificationResent) {
            // TODO :
          } else if (state is EmailVerificationError) {
            // TODO :
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    Text(
                      'Verify Your Email',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: gap),
                    Text(
                      'We have sent a verification link to your email address.',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: gap),
                    Text(
                      email,
                      style: TextStyle(
                        color: ColourPallette.textDarkColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: gap),
                    Text(
                      'Click the link in the email to verify your account.',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  MediaRes.mailboxBroSVG,
                  semanticsLabel: 'Login Logo',
                  height: size.height * .4,
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0,
                    0, // R' = 0.2126R + 0.7152G + 0.0722B
                    0.2126, 0.7152, 0.0722, 0, 0, // G' = same
                    0.2126, 0.7152, 0.0722, 0, 0, // B' = same
                    0, 0, 0, 1, 0, // A' = 1·A (preserve alpha)
                  ]),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state is EmailVerificationLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () {
                          context.read<EmailVerificationBloc>().add(
                                ResendVerificationEmail(email),
                              );
                        },
                        child: const Text('Resend Email'),
                      ),
                    const SizedBox(height: gap),
                    RichText(
                      text: TextSpan(
                        text: "Don't forget to ",
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login',
                            style: textTheme.titleMedium?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.go(RoutePaths.login);
                              },
                          ),
                          TextSpan(
                            text: ' after verification.',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
