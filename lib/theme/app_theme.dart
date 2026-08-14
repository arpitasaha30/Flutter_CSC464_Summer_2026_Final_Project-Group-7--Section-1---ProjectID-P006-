import 'package:flutter/material.dart';

/// Centralized color palette and gradients for the whole app.
class AppColors {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5A4FCF);
  static const secondary = Color(0xFF00CEC9);
  static const background = Color(0xFFF5F4FB);
  static const chatBackground = Color(0xFFF0EEFB);
  static const gradientStart = Color(0xFF6C5CE7);
  static const gradientEnd = Color(0xFF8E7CFF);
  static const danger = Color(0xFFE74C3C);

  /// Rotating gradient pairs used for avatar initials so each person gets
  /// a consistent, distinct color based on their name.
  static const List<List<Color>> avatarGradients = [
    [Color(0xFFFF7675), Color(0xFFD63031)],
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    [Color(0xFF00B894), Color(0xFF55EFC4)],
    [Color(0xFFE17055), Color(0xFFFAB1A0)],
    [Color(0xFF0984E3), Color(0xFF74B9FF)],
    [Color(0xFFE84393), Color(0xFFFD79A8)],
    [Color(0xFF00CEC9), Color(0xFF81ECEC)],
    [Color(0xFFFDCB6E), Color(0xFFE17055)],
  ];
}

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0x1F6C5CE7),
        elevation: 4,
        height: 66,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
