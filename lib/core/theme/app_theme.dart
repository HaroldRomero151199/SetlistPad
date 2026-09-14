import 'package:flutter/material.dart';

/// Centralized Theme and Color Palette for SetlistPad
abstract final class AppTheme {
  // Brand / Seed Colors
  static const Color primaryColor = Color(0xFF7C4DFF); // Deep Purple Accent / Vibrant Violet
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal Accent
  static const Color backgroundColor = Color(0xFF121212); // Modern Dark Surface
  static const Color surfaceColor = Color(0xFF1E1E2C); // Card / Elevated Surface
  static const Color cardColor = Color(0xFF252538);

  // Status & Text Colors
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFA0A0B2);
  static const Color accentIcon = Color(0xFF9D65FF);

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 2,
      ),
    );
  }
}
