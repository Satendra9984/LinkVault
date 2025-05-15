import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/presentation/blocs/forget_password_bloc/forget_password_bloc.dart';
import 'package:link_vault/src/authentication/presentation/widgets/custom_textfield.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_button.dart';

class ForgetPasswordResetPage extends StatefulWidget {
  const ForgetPasswordResetPage({super.key});

  @override
  State<ForgetPasswordResetPage> createState() =>
      _ForgetPasswordResetPageState();
}

class _ForgetPasswordResetPageState extends State<ForgetPasswordResetPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final colorScheme = appTheme.colorScheme;
    final textTheme = appTheme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        // actions: [
        // TextButton(
        //   onPressed: () {},
        //   child: Text(
        //     'skip',
        //     style: textTheme.bodyLarge,
        //   ),
        // ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                softWrap: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Please enter your email address to request a password reset',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextFormField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              BlocConsumer<ForgetPasswordBloc, ForgetPasswordState>(
                listener: (context, state) async {
                  if (state.isSuccess) {
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }
                    context.replace(RoutePaths.login);
                  }

                  if (state.isFailure) {
                    // SHOW ERROR SCAFFOLD MESSAGE
                    showSnackbar(
                      context: context,
                      title: 'Error',
                      subtitle: state.errorMessage,
                    );
                  }
                },
                builder: (context, state) {
                  final forgerPassCubit = context.read<ForgetPasswordBloc>();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          label: Text(
                            'Send Reset Link',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              forgerPassCubit.add(
                                SendResetEmail(
                                  _emailController.text,
                                ),
                              );
                            }
                          },
                          icon: state.isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    color: ColourPallette.bitterlemon,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: 'You remember your password? ',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Login',
                              style: textTheme.titleMedium,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
