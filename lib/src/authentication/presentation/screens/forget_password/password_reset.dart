import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_event.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_state.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/src/authentication/presentation/screens/forget_password/check_email_page.dart';
import 'package:link_vault/src/authentication/presentation/widgets/custom_textfield.dart';

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
      appBar: AppBar(
        backgroundColor: ColourPallette.white,
      ),
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
              BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state.isSuccess) {
                    // TODO: HANDLE NAVIGATION
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (ctx) => const CheckYourEmailPage(),
                    //   ),
                    // );
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
                  final forgerPassCubit = context.read<LoginBloc>();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          text: 'Send Reset Password',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              forgerPassCubit.add(
                                ForgotPassword(
                                  email: _emailController.text,
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
