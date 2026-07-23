import 'package:flutter/material.dart';

class AppTheme {
  static const Color deepNavyBlue = Color(0xFF001F3F);
  static const Color cyan = Color(0xFF00FFFF);

  static ThemeData getTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepNavyBlue,
        primary: cyan,
        secondary: cyan,
        surface: deepNavyBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: deepNavyBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepNavyBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: cyan,
        foregroundColor: deepNavyBlue,
      ),
      useMaterial3: true,
      fontFamily: 'Amiri',
    );
  }
}
