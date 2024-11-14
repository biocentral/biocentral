import 'package:flutter/material.dart';

class BiocentralStyle {
  static ThemeData darkTheme = ThemeData(
      useMaterial3: false,
      // Define the default brightness and colors.
      brightness: Brightness.dark,
      primaryColor: const Color(0x008e4dde),
      colorScheme: const ColorScheme.dark(secondary: Color(0xFF00513A), tertiary: Color(0xFFB9586C)),

      // Define the default font family.
      fontFamily: 'Georgia',

      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: const TextTheme(
        labelMedium: TextStyle(fontSize: 14, color: Colors.white),
        labelLarge: TextStyle(fontSize: 16, color: Colors.white),
        displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 12, color: Colors.white),
        titleLarge: TextStyle(fontSize: 36, fontStyle: FontStyle.italic),
        titleMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 18),
      ),);
}
