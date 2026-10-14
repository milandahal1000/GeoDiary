import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The application theme built from the design specification.
class AppTheme {
  /// Returns the light theme data.
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(AppColors.primaryGreen),
        brightness: Brightness.light,
      ).copyWith(surface: Color(AppColors.surface)),
      scaffoldBackgroundColor: Color(AppColors.background),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F8F5), // matches background
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
