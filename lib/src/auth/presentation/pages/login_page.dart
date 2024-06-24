import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication_cubit.dart';
import 'package:link_vault/src/auth/presentation/models/auth_states_enum.dart';
import 'package:link_vault/src/auth/presentation/pages/signup_page.dart';
import 'package:link_vault/src/auth/presentation/widgets/container_button.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_button.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_textfield.dart';

// ignore: public_member_api_docs
class LoginPage extends StatefulWidget {
  // static const routeName = '/login';

  const LoginPage({super.key});

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

  void _submitForm(AuthenticationCubit authenticationCubit) {
    if (_formKey.currentState!.validate()) {
      authenticationCubit.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
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
    return Scaffold(
      backgroundColor: ColourPallette.white,
      // appBar: AppBar(
      //   backgroundColor: ColourPallette.white,
      //   title: Text(
      //     'Welcome Back',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.grey.shade800,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          height: size.height,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: gap * 2),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Login to continue',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    // Image.asset(
                    //   'assets/logo/infinite_loop.jpg',
                    //   fit: BoxFit.contain,
                    //   height: 56,
                    // ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SvgPicture.asset(
                      // 'assets/images/login.svg',
                      'assets/images/login_password.svg',
                    
                      semanticsLabel: 'Login Logo',
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    // const SizedBox(height: gap),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // [TODO]:COMPLETE FORGET PASSWORD
                      },
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: ColourPallette.salemgreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    BlocConsumer<AuthenticationCubit, AuthenticationState>(
                      listener: (context, state) {
                        debugPrint(
                            '[log] : authstate ${state.authenticationStates}');

                        if (state.authenticationStates ==
                            AuthenticationStates.signedIn) {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (ctx) => const NewsListPage(),
                          //   ),
                          // );
                        }

                        if (state.authenticationStates ==
                            AuthenticationStates.errorSigningIn) {
                          // [TODO] : ScaffoldMessenger
                        }
                      },
                      builder: (context, state) {
                        final authcubit = context.read<AuthenticationCubit>();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                text: 'Login',
                                onPressed: () {
                                  _submitForm(authcubit);
                                },
                                icon: state.authenticationStates ==
                                        AuthenticationStates.signingIn
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: gap),
                            SizedBox(
                              width: double.infinity,
                              child: ContainerButton(
                                text: 'Sign Up',
                                onPressed: () {
                                  _submitForm(authcubit);
                                },
                                backgroundColor:
                                    ColourPallette.salemgreen.withOpacity(0.10),
                                textColor: ColourPallette.salemgreen,
                              ),
                            ),
                            // const SizedBox(height: gap - 6),

                            // RichText(
                            //   text: TextSpan(
                            //     text: ' New here? ',
                            //     style: const TextStyle(
                            //       color: Colors.black,
                            //       fontWeight: FontWeight.w400,
                            //       fontSize: 16,
                            //     ),
                            //     children: <TextSpan>[
                            //       TextSpan(
                            //         text: 'Sign Up',
                            //         style: const TextStyle(
                            //           color: ColourPallette.salemgreen,
                            //           fontSize: 16,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //         recognizer: TapGestureRecognizer()
                            //           ..onTap = () {
                            //             if (state.authenticationStates ==
                            //                 AuthenticationStates.signingIn) {
                            //               return;
                            //             }
                            //             // debugPrint('[log] : tapping SignUp');
                            //             Navigator.pushReplacement(
                            //               context,
                            //               // ignore: inference_failure_on_instance_creation
                            //               MaterialPageRoute(
                            //                 builder: (ctx) => const SignUpPage(),
                            //               ),
                            //             );
                            //           },
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
