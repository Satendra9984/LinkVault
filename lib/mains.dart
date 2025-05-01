import 'package:flutter/material.dart';

void main() {
  runApp(
    const LinkVaultApp(),
  );
}

class LinkVaultApp extends StatelessWidget {
  const LinkVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // backgroundColor: Color(0xff242426),
        backgroundColor: Color(0xfffffbf8),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Color(0xff242426),
                ),
              ),
              Expanded(
                child: Container(
                  color: Color(0xfff3efee),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
