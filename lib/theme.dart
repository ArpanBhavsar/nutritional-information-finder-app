import 'package:flutter/material.dart';

class AppTheme {
  static const Color _lightPrimaryColor = Color(0xFF2ECC71); // Emerald
  static const Color _lightSecondaryColor = Color(0xFF3498DB); // Sky Blue
  static const Color _lightAccentColor = Color(0xFF27AE60); // Nephritis
  static const Color _lightNeutralColor = Color(0xFFECF0F1); // Light Gray

  static const Color _darkPrimaryColor = Color(0xFF1A804D);
  static const Color _darkSecondaryColor = Color(0xFF246392);
  static const Color _darkAccentColor = Color(0xFF1B7A43); //Dark variation of Nephritis
  static const Color _darkNeutralColor = Color(0xFF2C3E50);

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightSecondaryColor,
      surface: _lightNeutralColor,
    ),
    scaffoldBackgroundColor: _lightNeutralColor,
    appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.black,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightAccentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(        
        backgroundColor: _lightAccentColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkSecondaryColor,
      surface: _darkNeutralColor,
    ),
    scaffoldBackgroundColor: _darkNeutralColor,
    appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkAccentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(        
        backgroundColor: _darkAccentColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}