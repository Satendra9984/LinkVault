import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: NetworkImage(
                'https://dev.to/social_previews/article/430257.png'),
            fit: BoxFit.contain,
          )),
        ),
      ),
    );
  }
}
