import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_event.dart';
import 'package:link_vault/src/authentication/presentation/blocs/login_bloc/login_state.dart';
import 'package:link_vault/src/authentication/presentation/screens/forget_password/password_reset.dart';
import 'package:link_vault/src/authentication/presentation/widgets/custom_textfield.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_button.dart';

// ignore: public_member_api_docs
class LoginPage extends StatefulWidget {
  // static const routeName = '/login';

  const LoginPage({
    super.key,
    this.returnPath,
  });

  final String? returnPath;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (BuildContext context, LoginState state) {},
            builder: (context, state) {
              final authcubit = context.read<LoginBloc>();
              return Form(
                key: _formKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome \nBack!',
                          style: textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          softWrap: true,
                        ),
                        const SizedBox(height: gap),
                        Text(
                          // ignore: lines_longer_than_80_chars
                          'Login to continue in the app and access all of your links again.',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: gap * 1.25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: gap * 0.5),
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: 'Password',
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: gap),
                        // const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            authcubit.add(
                              ForgotPassword(
                                email: _emailController.text,
                              ),
                            );

                            context.push(RoutePaths.forgetPassword);
                          },
                          child: Text(
                            'Forget Password',
                            style: textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: gap),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // OpenOtherApps.openGmailApp();
                                  if (_formKey.currentState!.validate()) {
                                    context.read<LoginBloc>().add(
                                          LoginWithCredentials(
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
                                label: Text(
                                  'Login',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: gap * 1.25),
                            RichText(
                              text: TextSpan(
                                text: "Dont't have an account? ",
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: textTheme.titleMedium,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (state.isSubmitting) {
                                          return;
                                        }
                                        context.replace(RoutePaths.signUp);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Expanded(
                    //   child: SvgPicture.asset(
                    //     MediaRes.loginPasswordSVG,
                    //     semanticsLabel: 'Login Logo',
                    //     alignment: Alignment.bottomCenter,
                    //   ),
                    // ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
