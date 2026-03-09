import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pastel Light Mode (Dribbble Concept)
  static ThemeData get pastelLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFA78BFA), // Soft Purple
        secondary: Color(0xFF81D4FA), // Sky Blue
        surface: Color(0xFFFFFFFF), // White cards
        surfaceContainerHighest: Color(0xFFF0EFE9), // Slightly darker panels
        onSurface: Color(0xFF2D2D2D), // Deep charcoal text
      ),
      scaffoldBackgroundColor: const Color(
        0xFFF8F7F3,
      ), // Off-white/cream background
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            titleLarge: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
              letterSpacing: 0.5,
            ),
            titleMedium: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
            bodyMedium: GoogleFonts.inter(color: const Color(0xFF555555)),
            labelSmall: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF888888),
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF2D2D2D),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: const Color(
          0xFFA78BFA,
        ).withValues(alpha: 0.15), // Diffuse pastel shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: const Color(0xFFA78BFA), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA78BFA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
