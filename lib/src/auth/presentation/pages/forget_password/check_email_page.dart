// [UI] https://dribbble.com/shots/16519810-Xigman-Reset-Password

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_button.dart';
import 'package:link_vault/src/auth/presentation/widgets/custom_textfield.dart';

class CheckYourEmailPage extends StatefulWidget {
  const CheckYourEmailPage({super.key});

  @override
  State<CheckYourEmailPage> createState() => _CheckYourEmailPageState();
}

class _CheckYourEmailPageState extends State<CheckYourEmailPage> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Your Email',
                  style: TextStyle(
                    color: ColourPallette.textDarkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'We have sent a link to reset password to your email address.',
                  style: TextStyle(
                    color: ColourPallette.textDarkColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  MediaRes.mailboxBro,
                  semanticsLabel: 'Login Logo',
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: 'Open Email App',
                    onPressed: () {},
                    // icon:null,
                    // state.authenticationStates ==
                    //         AuthenticationStates.signingIn
                    //     ?
                    //     const SizedBox(
                    //   height: 24,
                    //   width: 24,
                    //   child: CircularProgressIndicator(
                    //     backgroundColor: Colors.white,
                    //     color: ColourPallette.bitterlemon,
                    //   ),
                    // )
                    // : null,
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
            ),
          ],
        ),
      ),
    );
  }
}
