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

  /// Stored in `lv_collections.color_hex` when the user picks "No colour".
  static const String collectionCoverNoColor = 'none';

  /// More vibrant collection colors (hex strings), plus extra pastels.
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
    '#E8D4FF', // Soft Violet
    '#FFB4C0', // Blush
    '#B8F4D4', // Seafoam
    '#FFE4B5', // Moccasin
    '#C4E7F2', // Powder Blue
    '#F5E6D3', // Sand
    '#D8F0E4', // Sage Mist
    '#E6E0F8', // Lilac Mist
    '#FFD4A3', // Apricot
    '#B3D9FF', // Sky
    '#F0D9FF', // Orchid Tint
  ];

  static bool isCollectionCoverNoColor(String hex) =>
      hex.trim().toLowerCase() == collectionCoverNoColor;

  /// Parsed cover colour, or null for [collectionCoverNoColor] / invalid hex.
  static Color? tryParseCollectionColorHex(String hex) {
    if (isCollectionCoverNoColor(hex)) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  /// Fill / neutral swatch for list cards and form preview when cover is unset.
  static Color resolveCollectionCoverColor(String hex, ThemeData theme) {
    final parsed = tryParseCollectionColorHex(hex);
    if (parsed != null) return parsed;
    if (isCollectionCoverNoColor(hex)) {
      return theme.colorScheme.surfaceContainerHighest;
    }
    return const Color(0xFFB3E0FF);
  }

  /// Tint for emoji [ColorFilter] and category-picker chips when cover is "none".
  static Color collectionCoverEmojiTint(String hex, ThemeData theme) {
    final parsed = tryParseCollectionColorHex(hex);
    if (parsed != null) return parsed;
    return theme.colorScheme.primary;
  }

  /// Normalizes [color] to `#RRGGBB` for `color_hex` (opaque RGB only).
  static String colorToHexRgb(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// True when [hex] is a valid RGB cover colour not in [collectionColorHexes] (and not `none`).
  static bool isUserCustomCoverHex(String hex) {
    if (isCollectionCoverNoColor(hex)) return false;
    if (tryParseCollectionColorHex(hex) == null) return false;
    final normalized = hex.trim().toUpperCase();
    return !collectionColorHexes
        .map((e) => e.trim().toUpperCase())
        .contains(normalized);
  }

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
