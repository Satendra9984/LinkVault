import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_bloc.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_event.dart';
import 'package:link_vault/src/authentication/presentation/blocs/sign_bloc/signup_state.dart';
import 'package:link_vault/src/authentication/presentation/widgets/custom_textfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // final _bioController = TextEditingController();
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

    List<String> missingRequirements = [];

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      missingRequirements.add('lowercase letter');
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      missingRequirements.add('uppercase letter');
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      missingRequirements.add('number');
    }

    if (!RegExp(r'[.!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(value)) {
      missingRequirements.add('special character');
    }

    if (missingRequirements.isNotEmpty) {
      if (missingRequirements.length == 1) {
        return 'Password must contain at least one ${missingRequirements.first}';
      } else if (missingRequirements.length == 2) {
        return 'Password must contain at least one ${missingRequirements.join(' and ')}';
      } else {
        final lastRequirement = missingRequirements.removeLast();
        return 'Password must contain at least one ${missingRequirements.join(', ')}, and $lastRequirement';
      }
    }

    return null; // Password is valid
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
        foregroundColor: colorScheme.onSurface,
        actions: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
                return;
              }

              // TODO: GO TO HOME PAGE
            },
            child: Text(
              'skip',
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      body: BlocConsumer<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state.isFailure) {
            showSnackbar(
              context: context,
              title: 'Error',
              subtitle: state.errorMessage,
            );
          } else if (state.isSuccess) {
            context.replace(
              // ignore: lines_longer_than_80_chars
              '${RoutePaths.signUp}${RoutePaths.verifyEmail}?email=${Uri.encodeComponent(_emailController.text)}',
            );
          }
        },
        builder: (context, state) {
          final signUpBloc = context.read<SignupBloc>();
          return SingleChildScrollView(
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
                          validator: _validateName,
                          labelText: 'Name',
                          keyboardType: TextInputType.name,
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: gap * .5),
                        CustomTextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          labelText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: gap * .5),
                        CustomTextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          labelText: 'Password',
                          obscureText: true,
                          prefixIcon: Icon(
                            Icons.password_outlined,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: gap * .5),
                        // CustomTextFormField(
                        //   controller: _bioController,
                        //   validator: (_) => null,
                        //   labelText: 'Bio(optional)',
                        //   prefixIcon: Icon(
                        //     Icons.description_outlined,
                        //     color: colorScheme.primary,
                        //   ),
                        // ),
                        const SizedBox(height: 2 * gap),

                        Column(
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
                            const SizedBox(height: gap * 1.5),
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
          );
        },
      ),
    );
  }
}
