import 'package:flutter/material.dart';

class BiocentralStyle {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF6B4EE6),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6B4EE6),
      secondary: Color(0xFF2A9D8F),
      tertiary: Color(0xFF9D8FFF),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFE57373),
    ),
    textTheme: const TextTheme(
      labelMedium: TextStyle(fontSize: 14, color: Colors.white),
      labelLarge: TextStyle(fontSize: 16, color: Colors.white),
      displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontSize: 12, color: Colors.white),
      titleLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 18, color: Colors.white),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF007AFF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007AFF),
      secondary: Color(0xFF8E8E93),
      tertiary: Color(0xFF34C759),
      surface: Color(0xFFE5E5EA),
      error: Color(0xFFFF3B30),
    ),
    textTheme: const TextTheme(
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
      displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.black),
      displaySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
      titleLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: Colors.black),
      titleMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black),
    ),
  );
}
