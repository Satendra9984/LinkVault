import 'package:flutter/material.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Ubuntu',
  colorScheme: const ColorScheme.light(
    primary: Colors.white, // primary color for light theme
    onPrimary: Colors.black, // color for text and icons on primary color
    surface: Colors.white, // background color for components like AppBar
    onSurface: Colors.black, // color for text and icons on surface color
  ),
  primaryColor: Colors.white,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white, // sets the AppBar background color
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
    fontFamily: 'Ubuntu',
    primarySwatch: Colors.grey,
    // brightness: Brightness.dark,
  );
}
