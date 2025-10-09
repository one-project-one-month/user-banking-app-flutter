import 'package:flutter/material.dart';

class AppStyles {
  static const Color primary = Color(0xFF002D62);
  static const Color secondary = Color(0xFF1A73E8);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppStyles.primary,
  scaffoldBackgroundColor: AppStyles.background,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppStyles.secondary,
    error: AppStyles.error,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppStyles.textPrimary),
    bodyMedium: TextStyle(color: AppStyles.textSecondary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppStyles.primary,
    foregroundColor: Colors.white,
  ),
);
