import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication_cubit.dart';
import 'package:link_vault/src/auth/presentation/models/auth_states_enum.dart';
import 'package:link_vault/src/auth/presentation/pages/login_page.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_button.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_textfield.dart';

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
    const gap = 24.0;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColourPallette.backgroundCream,
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColourPallette.salemgreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: size.height - 32 - 50,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: gap - 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      controller: _nameController,
                      labelText: 'Name',
                      keyboardType: TextInputType.name,
                      validator: _validateName,
                    ),
                    const SizedBox(height: gap),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: gap),
                    CustomTextFormField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: gap),
                  ],
                ),
                BlocConsumer<AuthenticationCubit, AuthenticationState>(
                  listener: (context, state) {
                    debugPrint('[log] : authstate $state');
                    if (state.authenticationStates ==
                        AuthenticationStates.signedUp) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const LoginPage(),
                        ),
                      );
                    }
                    if (state.authenticationStates ==
                        AuthenticationStates.errorSigningUp) {
                      // [TODO] : ScaffoldMessenger
                    }
                  },
                  builder: (context, state) {
                    final authcubit = context.read<AuthenticationCubit>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 200,
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
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: gap - 6),
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
                        const SizedBox(height: gap),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
