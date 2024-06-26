// [UI] https://dribbble.com/shots/16519810-Xigman-Reset-Password

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/auth/presentation/cubit/forget_password/forget_password_cubit.dart';
import 'package:link_vault/src/auth/presentation/models/forget_password_states.dart';
import 'package:link_vault/src/auth/presentation/pages/forget_password/check_email_page.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_button.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_textfield.dart';

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
    return Scaffold(
      backgroundColor: ColourPallette.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      color: ColourPallette.textDarkColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Please enter your email address to request a password reset',
                    style: TextStyle(
                      color: ColourPallette.textDarkColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 36),
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                listener: (context, state) {
                  if (state.forgetPasswordStates ==
                      ForgetPasswordStates.resetPasswordLinkSentSuccessfully) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const CheckYourEmailPage(),
                      ),
                    );
                  }

                  if (state.forgetPasswordStates ==
                      ForgetPasswordStates.errorSendingResetPasswordLink) {
                    // [TODO] : SHOW ERROR SCAFFOLD MESSAGE
                  }
                },
                builder: (context, state) {
                  final forgerPassCubit = context.read<ForgetPasswordCubit>();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          text: 'Send Reset Password',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              forgerPassCubit.sendResetPasswordLink(
                                email: _emailController.text,
                              );
                            }
                          },
                          icon: state.forgetPasswordStates ==
                                  ForgetPasswordStates.sendingEmailLink
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
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Login',
                              style: const TextStyle(
                                color: ColourPallette.salemgreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
