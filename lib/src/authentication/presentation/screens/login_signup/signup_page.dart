import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_event.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_state.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/login_page.dart';
import 'package:link_vault/src/authentication/presentation/widgets/custom_textfield.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  static const routeName = '/signUp';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const gap = 16.0;
    final size = MediaQuery.of(context).size;

    final appTheme = Theme.of(context);
    final colorScheme = appTheme.colorScheme;
    final textTheme = appTheme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'skip',
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 32,
          ),
          height: size.height,
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Let's \nGet Started",
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  softWrap: true,
                ),
                const SizedBox(height: gap),

                Text(
                  'By Creating an Account',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: gap * 1.25),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      controller: _nameController,
                      labelText: 'Name',
                      keyboardType: TextInputType.name,
                      validator: _validateName,
                    ),
                    const SizedBox(height: gap * .5),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: gap * .5),
                    CustomTextFormField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 2 * gap),
                    BlocConsumer<SignupBloc, SignupState>(
                      listener: (context, state) {
                        // TODO : HANDLE NAVIGATION
                      },
                      builder: (context, state) {
                        final signUpBloc = context.read<SignupBloc>();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                label: Text(
                                  'Sign Up',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    signUpBloc.add(
                                      SignupWithCredentials(
                                        email: _emailController.text,
                                        password: _passwordController.text,
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
                            const SizedBox(height: gap),
                            RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' Login',
                                    style: textTheme.titleMedium,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (state.isSubmitting) {
                                          return;
                                        }
                                        context.replace(RoutePaths.login);
                                      },
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(height: gap),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                // Expanded(
                //   child: SvgPicture.asset(
                //     MediaRes.loginSVG,
                //     semanticsLabel: 'Login Logo',
                //     alignment: Alignment.bottomCenter,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
