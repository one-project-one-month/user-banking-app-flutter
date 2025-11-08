// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'screens/auth/services/cache_service.dart';
// import 'screens/auth/models/token.dart';

// /// AppState provides simple app-wide state management for:
// /// - ThemeMode (persisted to SharedPreferences)
// /// - Logged-in status (derived from cached token)
// /// - Logout (clears cached auth data)
// ///
// /// Usage:
// /// final appState = await AppState.initialize();
// /// Provide it with a ChangeNotifierProvider or similar.
// class AppState extends ChangeNotifier {
//   static const String _themeKey = 'app_theme_mode';

//   final CacheService _cache;

//   ThemeMode _themeMode = ThemeMode.system;
//   bool _isLoggedIn = false;

//   AppState({CacheService? cacheService}) : _cache = cacheService ?? CacheService();

//   /// Initialize AppState and load persisted values.
//   static Future<AppState> initialize({CacheService? cacheService}) async {
//     final instance = AppState(cacheService: cacheService);
//     await instance._load();
//     return instance;
//   }

//   Future<void> _load() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeStr = prefs.getString(_themeKey);
//     if (themeStr != null) {
//       _themeMode = _themeModeFromString(themeStr);
//     }

//     try {
//       final Token? t = await _cache.getToken();
//       _isLoggedIn = t != null;
//     } catch (_) {
//       _isLoggedIn = false;
//     }
//   }

//   ThemeMode get themeMode => _themeMode;

//   bool get isLoggedIn => _isLoggedIn;

//   /// Set the theme mode and persist the choice.
//   Future<void> setThemeMode(ThemeMode mode) async {
//     if (_themeMode == mode) return;
//     _themeMode = mode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_themeKey, _themeModeToString(mode));
//     notifyListeners();
//   }

//   /// Toggle between light and dark. If current is system, switch to dark.
//   Future<void> toggleTheme() async {
//     if (_themeMode == ThemeMode.dark) {
//       await setThemeMode(ThemeMode.light);
//     } else {
//       await setThemeMode(ThemeMode.dark);
//     }
//   }

//   /// Mark user as logged in (useful after successful auth operations).
//   void markLoggedIn() {
//     _isLoggedIn = true;
//     notifyListeners();
//   }

//   /// Logout: clears auth cache and notifies listeners.
//   Future<void> logout() async {
//     await _cache.clearAll();
//     _isLoggedIn = false;
//     notifyListeners();
//   }

//   // --- helpers ---
//   static String _themeModeToString(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return 'light';
//       case ThemeMode.dark:
//         return 'dark';
//       case ThemeMode.system:
//         return 'system';
//     }
//   }

//   static ThemeMode _themeModeFromString(String s) {
//     switch (s) {
//       case 'light':
//         return ThemeMode.light;
//       case 'dark':
//         return ThemeMode.dark;
//       case 'system':
//       default:
//         return ThemeMode.system;
//     }
//   }
// }
