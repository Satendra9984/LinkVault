// ignore_for_file: avoid_redundant_argument_values, public_member_api_docs

import 'package:flutter/material.dart';

// https://m2.material.io/design/color/the-color-system.html#color-theme-creation
class AppThemes {
  static ThemeData getThemeDataFromString(String theme) {
    return switch (theme) {
      'light' => lightTheme,
      _ => darkTheme,
    };
  }

  // LIGHT THEME
  static ThemeData lightTheme = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    // COLOR SCHEME
    colorScheme: const ColorScheme.light(
      // PRIMARY COLORS
      // Used for key components like app bars, buttons, and other interactive elements
      // Main brand color, used for primary buttons, app bar
      primary: Color(0xff232326),
      // Text/icons on primary color (white for contrast)
      onPrimary: Color(0xffFFFFFF),
      // Background of cards, dialogs containing primary content
      primaryContainer: Color(0xffE9E9E9),
      // Text/icons on primary containers
      onPrimaryContainer: Color(0xff232326),
      // SECONDARY COLORS
      // Used for less prominent components, accents, and highlights
      // Used for FABs, selection controls, highlights
      secondary: Color(0xffE9E9E9),
      // Text/icons on secondary color
      onSecondary: Color(0xff232326),
      // Background for secondary components like chips
      secondaryContainer: Color(0xffD0D0D0),
      // Text on secondary containers
      onSecondaryContainer: Color(0xff232326),

      // SURFACE COLORS
      // Used for backgrounds, cards, sheets, etc.
      // Main background for widgets/screens
      surface: Color(0xffF0F0F0),
      // Primary text on surfaces
      onSurface: Color(0xff232326),
      // Alternative surface for nested components
      surfaceContainer: Color(0xffE9E9E9),
      // For elevated components like cards
      surfaceContainerLow: Color(0xffF8F8F8),
      // For more prominently elevated components
      surfaceContainerHigh: Color(0xffE0E0E0),

      // NEUTRAL VARIANTS
      // Used for backgrounds, borders, dividers
      // Borders, dividers, and subtle outlines
      outline: Color(0xffA0A0A0),
      // Less prominent dividers, disabled state borders
      outlineVariant: Color(0xffC4C4C4),

      // ERROR COLORS
      // Used for error states and validation
      // Error messaging, validation borders, error icons
      error: Color(0xffB00020),
      // Text/icons on error color
      onError: Color(0xffffffff),
      // Light background for error messages/states
      errorContainer: Color(0xffFDECEF),
      // Error text on container backgrounds
      onErrorContainer: Color(0xffB00020),

      // ADDITIONAL COLORS
      // For specific use cases
      // Main app background
      background: Color(0xffF5F5F5),
      // Text/icons on main background
      onBackground: Color(0xff232326),
      // Shadow color for elevated components
      shadow: Color(0x40000000),
    ),

    // TEXT THEME
    textTheme: const TextTheme(
      // DISPLAY STYLES - Used for the largest text elements, usually headers
      displayLarge: TextStyle(
        fontSize: 57, // Very large headers, splash screens
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
        color: Color(0xff232326),
      ),
      displayMedium: TextStyle(
        fontSize: 45, // Large page headers, welcome screens
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        color: Color(0xff232326),
      ),
      displaySmall: TextStyle(
        fontSize: 36, // Medium headers, section dividers
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        color: Color(0xff232326),
      ),

      // HEADLINE STYLES - Used for important text that's smaller than display
      headlineLarge: TextStyle(
        fontSize: 32, // Main page titles, major section headers
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xff232326),
      ),
      headlineMedium: TextStyle(
        fontSize: 28, // Secondary headers, dialog titles
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xff232326),
      ),
      headlineSmall: TextStyle(
        fontSize: 24, // Minor section headers, card titles
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xff232326),
      ),

      // TITLE STYLES - Used for medium emphasis titles
      titleLarge: TextStyle(
        fontSize: 22, // Main content titles, important list items
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xff232326),
      ),
      titleMedium: TextStyle(
        fontSize: 16, // Standard app bar titles, button text
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: Color(0xff232326),
      ),
      titleSmall: TextStyle(
        fontSize: 14, // Small titles, tab labels, section labels
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Color(0xff232326),
      ),

      // BODY STYLES - Used for the main body text throughout the app
      bodyLarge: TextStyle(
        fontSize: 16, // Primary body text, list items, descriptions
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Color(0xff232326),
      ),
      bodyMedium: TextStyle(
        fontSize: 14, // Secondary body text, menu items, input text
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: Color(0xff232326),
      ),
      bodySmall: TextStyle(
        fontSize: 12, // Captions, helper text, timestamps
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: Color(0xff666666), // Slightly lighter for less emphasis
      ),

      // LABEL STYLES - Used for smaller UI elements like labels and buttons
      labelLarge: TextStyle(
        fontSize: 14, // Button text, important labels
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Color(0xff232326),
      ),
      labelMedium: TextStyle(
        fontSize: 12, // Secondary buttons, tabs, chips
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Color(0xff232326),
      ),
      labelSmall: TextStyle(
        fontSize: 11, // Smallest labels, form field labels, hints
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Color(0xff666666), // Slightly lighter for less emphasis
      ),
    ),

    // ADDITIONAL THEME PROPERTIES
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff232326),
      foregroundColor: Color(0xffFFFFFF),
      elevation: 0,
    ),

    cardTheme: const CardTheme(
      color: Color(0xffF0F0F0),
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xffFFFFFF),
        backgroundColor: Color(0xff232326),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xff232326),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: Color(0xff232326)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xff232326),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // DARK THEME
  static ThemeData darkTheme = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    // COLOR SCHEME
    colorScheme: const ColorScheme.dark(
      // PRIMARY COLORS
      // Inverted from light theme for proper dark mode contrast
      // Light color for contrast against dark background
      primary: Color(0xffE0E0E0),
      // Dark text on light primary for readability
      onPrimary: Color(0xff232326),
      // Slightly lighter than background for containers
      primaryContainer: Color(0xff3A3A3E),
      // Light text for contrast
      onPrimaryContainer: Color(0xffE0E0E0),

      // SECONDARY COLORS
      // Mid-tone gray for secondary elements
      secondary: Color(0xff787878),
      // Light text on secondary elements
      onSecondary: Color(0xffE0E0E0),
      // Slightly elevated container background
      secondaryContainer: Color(0xff4A4A4E),
      // Light text for contrast
      onSecondaryContainer: Color(0xffE0E0E0),

      // SURFACE COLORS
      // Main dark surface color
      surface: Color(0xff121214),
      // Light text for contrast
      onSurface: Color(0xffE0E0E0),
      // Slightly lighter surface for containers
      surfaceContainer: Color(0xff232326),
      // Slightly elevated surface
      surfaceContainerLow: Color(0xff1A1A1D),
      // More prominently elevated surface
      surfaceContainerHigh: Color(0xff2C2C30),

      // NEUTRAL VARIANTS
      outline: Color(0xff848484), // Visible borders and dividers
      outlineVariant: Color(0xff5A5A5A), // Subtler borders and dividers

      // ERROR COLORS
      error: Color(0xffCF6679), // Softer red for dark theme errors
      onError: Color(0xff000000), // Dark text on error color
      errorContainer: Color(0xff442A30), // Dark container for error states
      onErrorContainer: Color(0xffCF6679), // Error text on container

      // ADDITIONAL COLORS
      background: Color(0xff121214), // App background (darker than light theme)
      onBackground: Color(0xffE0E0E0), // Light text for contrast
      shadow: Color(0x80000000), // Stronger shadow for dark theme
    ),

    // TEXT THEME FOR DARK MODE
    textTheme: const TextTheme(
      // DISPLAY STYLES
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
        color: Color(0xffE0E0E0), // Light text for dark backgrounds
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        color: Color(0xffE0E0E0),
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        color: Color(0xffE0E0E0),
      ),

      // HEADLINE STYLES
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xffE0E0E0),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xffE0E0E0),
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xffE0E0E0),
      ),

      // TITLE STYLES
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xffE0E0E0),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: Color(0xffE0E0E0),
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Color(0xffE0E0E0),
      ),

      // BODY STYLES
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Color(0xffE0E0E0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: Color(0xffE0E0E0),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: Color(0xffAAAAAA), // Slightly darker for less emphasis
      ),

      // LABEL STYLES
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Color(0xffE0E0E0),
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Color(0xffE0E0E0),
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Color(0xffAAAAAA), // Slightly darker for less emphasis
      ),
    ),

    // ADDITIONAL THEME PROPERTIES FOR DARK MODE
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff232326),
      foregroundColor: Color(0xffE0E0E0),
      elevation: 0,
    ),

    cardTheme: const CardTheme(
      color: Color(0xff232326),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xff232326),
        backgroundColor: Color(0xffE0E0E0),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xffE0E0E0),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: Color(0xffE0E0E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xffE0E0E0),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

/*
I'll analyze your light theme and create a dark theme with detailed comments on each component of both the color scheme and text theme. This will help you understand where to use each element in your app.

## Analysis of Your Light Theme

Your light theme uses Material 3 with a clean, minimalist color palette:
- Primary: A dark gray/almost black (`#232326`)
- Secondary: A very light gray (`#E9E9E9`)
- Surface: An off-white (`#F0F0F0`)
- Error: A standard Material Design error red

Let me create a complementary dark theme and add text theme guidance for both.

## Theme Implementation Guide

I've created a comprehensive theme setup for your URL store app with both light and dark themes. Here's a breakdown of what I've added:

### Color Scheme Components

1. **Primary Colors**
   - Used for key UI elements like app bars, primary buttons, and key interactive components
   - In dark mode, these are inverted to maintain proper contrast

2. **Secondary Colors**
   - Used for less prominent elements like FABs, selection controls, and highlights
   - Provides visual variety while maintaining consistency

3. **Surface Colors**
   - Defines backgrounds, cards, and other container components
   - I added various surface container variants for different elevation levels

4. **Error Colors**
   - Used consistently for validation, error messages, and alerts
   - Dark theme uses softer error colors that are easier on the eyes

5. **Outline Colors**
   - Used for borders, dividers, and other separators

### Text Theme Usage Guide

I've added detailed comments for each text style to help you understand where to use them:

1. **Display Styles (Large, Medium, Small)**
   - For largest text elements like splash screens and major headers
   - Use sparingly for maximum impact

2. **Headline Styles (Large, Medium, Small)**
   - For important page and section titles
   - Great for dialog titles and primary content headers

3. **Title Styles (Large, Medium, Small)**
   - For medium-emphasis titles like card headers
   - Use for app bar titles and important list items

4. **Body Styles (Large, Medium, Small)**
   - Primary content text throughout your app
   - Body Large is your main paragraph text
   - Body Medium for secondary content
   - Body Small for captions and helper text

5. **Label Styles (Large, Medium, Small)**
   - Designed for UI elements like buttons and form fields
   - Maintains consistent text styling across interactive elements

### Additional Component Theming

I've also added theme configurations for common components:
- **AppBar theme** - Consistent styling for navigation bars
- **Card theme** - Proper elevation and colors for card components
- **Button themes** - Three button styles (elevated, outlined, text) with consistent looks

### Best Practices for Using This Theme

1. **Follow Hierarchy**: Use the text styles according to their intended hierarchy to maintain visual consistency.

2. **Color Consistency**: Stick to the color scheme defined in the theme. Don't introduce new colors unless absolutely necessary.

3. **Container Differentiation**: Use the different surface containers to create visual hierarchy through subtle elevation changes.

4. **Text Contrast**: The theme ensures proper text contrast in both light and dark modes.

5. **Theme Extension**: When you need to add new components, follow the established patterns for consistency.

Would you like me to explain any specific part of the theme in more detail?
*/
