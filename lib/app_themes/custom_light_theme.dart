import 'package:flutter/material.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(),
    primaryColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      // backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.black,
      ),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    ),
  );

  static final ThemeData dartTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(),
    // primaryColor: Colors.grey,
    primarySwatch: Colors.grey,
    // brightness: Brightness.dark,
  );
}
