import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/auth/presentation/models/auth_states_enum.dart';
import 'package:link_vault/src/auth/presentation/pages/login_signup/login_page.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_button.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_textfield.dart';
import 'package:link_vault/src/dashboard/presentation/dashboard.dart';

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

  void _submitForm(AuthenticationCubit cubit) {
    if (_formKey.currentState!.validate()) {
      cubit.signUpWithEmailAndPassword(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
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
    return Scaffold(
      backgroundColor: ColourPallette.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          height: size.height,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: gap * 2),
                        Text(
                          "Let's Get Started",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'By Creating an Account',
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
                      MediaRes.loginSVG,
                      semanticsLabel: 'Login Logo',
                    ),
                  ),
                ),
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
                    BlocConsumer<AuthenticationCubit, AuthenticationState>(
                      listener: (context, state) {
                        debugPrint('[log] : authstate $state');
                        if (state.authenticationStates ==
                            AuthenticationStates.signedUp) {
                          context
                              .read<GlobalUserCubit>()
                              .initializeGlobalUser(state.globalUser!);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const DashboardPage(),
                            ),
                            (route) => false,
                          );
                        }
                        if (state.authenticationStates ==
                            AuthenticationStates.errorSigningUp) {
                          // ScaffoldMessenger
                          showSnackbar(
                            context: context,
                            title: 'Something Went Wrong',
                            subtitle:
                                state.authenticationFailure?.errorMessage ?? '',
                          );
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
                                text: 'Signup',
                                onPressed: () => _submitForm(authcubit),
                                icon: state.authenticationStates ==
                                        AuthenticationStates.signingUp
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
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' Login',
                                    style: const TextStyle(
                                      color: ColourPallette.salemgreen,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (state.authenticationStates ==
                                            AuthenticationStates.signingUp) {
                                          return;
                                        }

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => const LoginPage(),
                                          ),
                                        );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
