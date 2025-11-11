import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// --------------------------------------------
/// BRAND COLORS
/// --------------------------------------------
class AppColors {
  // Core Brand Colors
  static const Color deepNavy = Color(0xFF1E3A5F);
  static const Color brightAmber = Color(0xFF2563EB);
  static const Color white = Color(0xFFFFFFFF);

  // Blue Shades
  static const Color blue = Color(0xFF2563EB);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  // Yellow Shades (Accent Colors - Slate Blue)
  static const Color yellow = Color(0xFF475569);
  static const Color yellow50 = Color(0xFFF8FAFC);
  static const Color yellow100 = Color(0xFFF1F5F9);
  static const Color yellow200 = Color(0xFFE2E8F0);
  static const Color yellow300 = Color(0xFFCBD5E1);
  static const Color yellow400 = Color(0xFF94A3B8);
  static const Color yellow500 = Color(0xFF64748B);
  static const Color yellow600 = Color(0xFF475569);
  static const Color yellow700 = Color(0xFF334155);
  static const Color yellow800 = Color(0xFF1E293B);
  static const Color yellow900 = Color(0xFF0F172A);

  // Neutral & Status Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color divider = Color(0xFFE2E8F0);
}

/// --------------------------------------------
/// TYPOGRAPHY
/// --------------------------------------------
class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.dmSans(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    headlineLarge: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    headlineMedium: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    titleLarge: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
    labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
  );
}

/// --------------------------------------------
/// LIGHT THEME
/// --------------------------------------------
final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.brightAmber,
  scaffoldBackgroundColor: AppColors.background,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brightAmber,
    onPrimary: AppColors.white,
    secondary: AppColors.deepNavy,
    onSecondary: AppColors.white,
    tertiary: AppColors.blue700,
    onTertiary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    surface: AppColors.white,
    onSurface: AppColors.textPrimary,
  ),

  textTheme: AppTypography.textTheme,

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.deepNavy,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.deepNavy,
      foregroundColor: AppColors.white,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.white,
    elevation: 3,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.deepNavy,
    contentTextStyle: GoogleFonts.inter(color: AppColors.white),
    behavior: SnackBarBehavior.floating,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.deepNavy,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
  ),

  dividerTheme: const DividerThemeData(color: AppColors.divider),
  iconTheme: const IconThemeData(color: AppColors.deepNavy),
);

/// --------------------------------------------
/// DARK THEME
/// --------------------------------------------
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.deepNavy,
  scaffoldBackgroundColor: AppColors.yellow900,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.blue400,
    onPrimary: AppColors.white,
    secondary: AppColors.brightAmber,
    onSecondary: AppColors.white,
    tertiary: AppColors.blue800,
    onTertiary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.yellow900,
    onBackground: AppColors.white,
    surface: AppColors.yellow800,
    onSurface: AppColors.white,
  ),

  textTheme: AppTypography.textTheme.apply(bodyColor: AppColors.white, displayColor: AppColors.white),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.yellow800,
    foregroundColor: AppColors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brightAmber,
      foregroundColor: AppColors.white,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.yellow800,
    hintStyle: GoogleFonts.inter(color: AppColors.yellow300),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.yellow700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.yellow700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.brightAmber, width: 2),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.yellow800,
    elevation: 2,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.brightAmber,
    contentTextStyle: GoogleFonts.inter(color: AppColors.white),
    behavior: SnackBarBehavior.floating,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.yellow800,
    selectedItemColor: AppColors.brightAmber,
    unselectedItemColor: AppColors.yellow300,
    type: BottomNavigationBarType.fixed,
  ),

  dividerTheme: const DividerThemeData(color: AppColors.yellow700),
  iconTheme: const IconThemeData(color: AppColors.white),
);
