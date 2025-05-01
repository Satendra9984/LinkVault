// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';

// https://m2.material.io/design/color/the-color-system.html#color-theme-creation
class AppThemes {
  static ThemeData lightTheme = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    colorScheme: const ColorScheme.light(
// A primary color is the color displayed most frequently across your app's screens and components.
      primary: Color(0xff232326),
      onPrimary: Color(0xffFFFFFF),
      primaryContainer: Color(0xffE9E9E9),
      onPrimaryContainer: Color(0xff232326),
/*
  A secondary color provides more ways to accent and distinguish your product. Having a secondary color is optional, and should be applied sparingly to accent select parts of your UI.

  If you don’t have a secondary color, your primary color can also be used to accent elements.

  Secondary colors are best for:

  Floating action buttons
  Selection controls, like sliders and switches
  Highlighting selected text
  Progress bars
  Links and headlines
*/
      secondary: Color(0xffE9E9E9),
      onSecondary: Color(0xff232326),

// Surface colors affect surfaces of components, such as cards, sheets, and menus.
      surface: Color(0xffF0F0F0),
      onSurface: Color(0xff232326),
      surfaceContainer: Color(0xffE9E9E9),

      error: Color(0xffB00020),
      onError: Color(0xffffffff),
      // errorContainer: ,
    ),
  );
}
