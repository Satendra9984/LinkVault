import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFFFF6B4A); // Behance Orange
  static const Color text = Color(0xFF2D3436); // Charcoal
  static const Color background = Color(0xFFF8F9FA); // Warm White
  static const Color surface = Colors.white;

  // Premium / Luxury Theme
  static const Color premiumDark =
      Color(0xFF121212); // Deep Charcoal / Jet Black
  static const Color premiumGold = Color(0xFFD4AF37); // Muted Elegant Gold
  static const Color premiumTextLight =
      Color(0xFFF5F5F7); // Off-white for stark contrast

  // Collection Colors (9 Pastel Tones from Behance)
  static const Color collectionBlue = Color(0xFFD4E4F7);
  static const Color collectionYellow = Color(0xFFFFF3CD);
  static const Color collectionDarkBlue = Color(0xFFD1EAED);
  static const Color collectionCyan = Color(0xFFD1F2F9);
  static const Color collectionPink = Color(0xFFFAD2E1);
  static const Color collectionPurple = Color(0xFFE2D9F3);
  static const Color collectionGreen = Color(0xFFD1E7DD);
  static const Color collectionDarkPurple = Color(0xFFC5CAE9);
  static const Color collectionLime = Color(0xFFE2F0CB);

  static const List<Color> collectionColors = [
    collectionBlue,
    collectionYellow,
    collectionDarkBlue,
    collectionCyan,
    collectionPink,
    collectionPurple,
    collectionGreen,
    collectionDarkPurple,
    collectionLime,
  ];

  // More vibrant collection colors (hex strings)
  static const List<String> collectionColorHexes = [
    '#B3E0FF', // Pale Blue
    '#FFD299', // Pale Apricot
    '#FFDAB9', // Peach
    '#8CE1E6', // Turquoise
    '#FF9E9E', // Coral Pink
    '#7AA1FF', // Periwinkle
    '#8AE8A2', // Mint
    '#C194FF', // Lavender
    '#D4FF8A', // Lime Green
  ];

  // Status Colors
  static const Color statusPending = Color(0xFF95A5A6);
  static const Color statusVisited = Color(0xFF27AE60);
  static const Color statusCompleted = Color(0xFFF39C12);

  // Semantic
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
}
