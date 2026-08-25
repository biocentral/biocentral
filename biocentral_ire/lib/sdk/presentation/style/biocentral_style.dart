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

  // Active Learning colors
  static const Color alTooltipBackground = Color(0xFF455A64);
  static const Color alTooltipTextColor = Colors.white;
  static const Color alConnectorLineColor = Colors.transparent;
  static const Color alPredictionErrorBodyColor = Color(0xFF673AB7);
  static const Color alPredictionLineColor = Colors.blue;
  static const Color alExperimentalLineColor = Colors.orange;
  static const Color alWarningColor = Colors.orange;
  static const Color alWarningBackgroundColor = Color(0xFFFFE0B2);
  static const Color alWarningTextColor = Color(0xFFEF6C00);
  static const Color alSuccessColor = Colors.green;
  static const Color alSuccessTextColor = Color(0xFF388E3C);
  static const Color alCriticalColor = Colors.red;
  static const Color alCriticalBackgroundColor = Color(0xFFFFCDD2);
  static const List<Color> alIterationColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.pink,
  ];
  static const List<Color> alScoreGradientColors = [
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.yellow,
  ];
}
