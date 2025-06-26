import 'package:flutter/material.dart';

class AppTheme {
  // Color Scheme
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color tertiaryColor = Color(0xFF81C784);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = Color(0xFF2196F3);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
        surface: surfaceLight,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: onSurfaceLight,
        onBackground: onBackgroundLight,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceLight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: backgroundLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: tertiaryColor,
        secondary: secondaryColor,
        tertiary: primaryColor,
        error: errorColor,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: onSurfaceDark,
        onBackground: onBackgroundDark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: tertiaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: tertiaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: tertiaryColor,
        foregroundColor: Colors.black,
      ),
    );
  }

  // Custom Colors for specific use cases
  static const Map<String, Color> categoryColors = {
    'Food & Dining': Color(0xFFFF6B6B),
    'Transportation': Color(0xFF4ECDC4),
    'Utilities': Color(0xFFFFE66D),
    'Healthcare': Color(0xFF95E1D3),
    'Education': Color(0xFF6C5CE7),
    'Shopping': Color(0xFFFF7675),
    'Entertainment': Color(0xFFFD79A8),
    'Travel': Color(0xFF00B894),
    'Bills': Color(0xFFE17055),
    'Groceries': Color(0xFF00CEC9),
    'Salary': Color(0xFF00B894),
    'Business': Color(0xFF6C5CE7),
    'Investment': Color(0xFF0984E3),
    'Other': Color(0xFF636E72),
  };

  // Account Colors
  static const Map<String, Color> accountColors = {
    'Cash': Color(0xFF00B894),
    'Bank Account': Color(0xFF0984E3),
    'Credit Card': Color(0xFFE17055),
    'Mobile Wallet': Color(0xFF6C5CE7),
    'Savings': Color(0xFF00CEC9),
  };

  // Status Colors
  static const Color incomeColor = Color(0xFF00B894);
  static const Color expenseColor = Color(0xFFE17055);
  static const Color transferColor = Color(0xFF6C5CE7);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    primaryColor,
    secondaryColor,
  ];

  static const List<Color> incomeGradient = [
    Color(0xFF00B894),
    Color(0xFF00CEC9),
  ];

  static const List<Color> expenseGradient = [
    Color(0xFFE17055),
    Color(0xFFFF7675),
  ];
}
