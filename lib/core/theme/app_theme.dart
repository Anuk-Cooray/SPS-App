import 'package:flutter/material.dart';

/// Uber-style Clean Design System for Smart Parking System (SPS)
class AppTheme {
  // Monochrome Primary Palette
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color mapAsphalt = Color(0xFFF1F5F9);
  static const Color mapLane = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Status & Brand Accents
  static const Color availableGreen = Color(0xFF10B981);
  static const Color availableGreenBg = Color(0xFFECFDF5);
  static const Color reservedAmber = Color(0xFFF59E0B);
  static const Color reservedAmberBg = Color(0xFFFFFBEB);
  static const Color occupiedRed = Color(0xFFEF4444);
  static const Color occupiedRedBg = Color(0xFFFEF2F2);
  static const Color aiIndigo = Color(0xFF4F46E5);
  static const Color aiIndigoBg = Color(0xFFEEF2FF);

  // Typography Palette
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Legacy & Compatibility Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFFFFFFFF);
  static const Color darkBorder = Color(0xFFE2E8F0);
  static const Color reoptIndigo = Color(0xFF4F46E5);
  static const Color violationDarkRed = Color(0xFFB91C1C);

  static ThemeData get uberLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: pureBlack,
        secondary: availableGreen,
        surface: surfaceCard,
        error: occupiedRed,
        onPrimary: pureWhite,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: pureBlack),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pureBlack,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: pureBlack,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
