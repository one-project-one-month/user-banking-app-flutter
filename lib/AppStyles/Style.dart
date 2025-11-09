import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// --------------------------------------------
/// BRAND COLORS
/// --------------------------------------------
class AppColors {
  // Core Brand Colors
  static const Color deepNavy = Color(0xFF0A3D62);
  static const Color brightAmber = Color(0xFFFFC107);
  static const Color white = Color(0xFFFFFFFF);

  // Blue Shades
  static const Color blue = Colors.blue;
  static const Color blue50 = Color(0xFFE7ECEF);
  static const Color blue100 = Color(0xFFB3C3CE);
  static const Color blue200 = Color(0xFF8EA6B7);
  static const Color blue300 = Color(0xFF5B7D96);
  static const Color blue400 = Color(0xFF3B6481);
  static const Color blue500 = Color(0xFF0A3D62);
  static const Color blue600 = Color(0xFF093859);
  static const Color blue700 = Color(0xFF072B46);
  static const Color blue800 = Color(0xFF062236);
  static const Color blue900 = Color(0xFF041A29);

  // Yellow Shades 
  static const Color yellow = Colors.yellow;
  static const Color yellow50 = Color(0xFFFFF9E6);
  static const Color yellow100 = Color(0xFFFFECB2);
  static const Color yellow200 = Color(0xFFFFE28D);
  static const Color yellow300 = Color(0xFFFFD559);
  static const Color yellow400 = Color(0xFFFFCD39);
  static const Color yellow500 = Color(0xFFFFC107);
  static const Color yellow600 = Color(0xFFE8B006);
  static const Color yellow700 = Color(0xFFB58905);
  static const Color yellow800 = Color(0xFF8C6A04);
  static const Color yellow900 = Color(0xFF6B5103);

  // Neutral & Status Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color divider = Color(0xFFE5E7EB);
}

/// --------------------------------------------
/// TYPOGRAPHY
/// --------------------------------------------
class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.dmSans(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    labelLarge: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
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
    onPrimary: AppColors.deepNavy,
    secondary: AppColors.deepNavy,
    onSecondary: AppColors.yellow,
        tertiary: AppColors.yellow400,
    onTertiary: AppColors.yellow500,
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    surface: AppColors.white,
    onSurface: AppColors.textPrimary,
  ),

  textTheme: AppTypography.textTheme,

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.brightAmber,
    foregroundColor: AppColors.deepNavy,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.deepNavy,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.deepNavy,
      foregroundColor: AppColors.white,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
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
  scaffoldBackgroundColor: AppColors.blue900,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.deepNavy,
    
    onPrimary: AppColors.white,
    secondary: AppColors.brightAmber,  
    onSecondary: AppColors.blue,
    tertiary: AppColors.blue400,
    onTertiary: AppColors.blue500,
  
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.blue900,
    onBackground: AppColors.white,
    surface: AppColors.blue800,
    onSurface: AppColors.white,
  ),

  textTheme: AppTypography.textTheme.apply(
    bodyColor: AppColors.white,
    displayColor: AppColors.white,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.deepNavy,
    foregroundColor: AppColors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brightAmber,
      foregroundColor: AppColors.deepNavy,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.blue800,
    hintStyle: GoogleFonts.inter(color: AppColors.yellow100),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.blue700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.blue700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.brightAmber, width: 2),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.blue800,
    elevation: 2,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.brightAmber,
    contentTextStyle: GoogleFonts.inter(color: AppColors.deepNavy),
    behavior: SnackBarBehavior.floating,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.blue800,
    selectedItemColor: AppColors.brightAmber,
    unselectedItemColor: AppColors.yellow700,
    type: BottomNavigationBarType.fixed,
  ),

  dividerTheme: const DividerThemeData(color: AppColors.blue700),
  iconTheme: const IconThemeData(color: AppColors.white),
);


