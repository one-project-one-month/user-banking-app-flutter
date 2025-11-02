import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/token.dart';
import '../models/registration_options.dart';

/// Simple cache wrapper around SharedPreferences for auth-related data.
class CacheService {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyRegistrationOptions = 'registration_options';

  Future<void> saveToken(Token token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, json.encode(token.toJson()));
  }

  Future<Token?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyToken);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> jsonBody = json.decode(raw);
      return Token.fromJson(jsonBody);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json.encode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> jsonBody = json.decode(raw);
      return jsonBody;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRegistrationOptions(Map<String, dynamic> options) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegistrationOptions, json.encode(options));
  }

  Future<RegistrationOptions?> getRegistrationOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRegistrationOptions);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> jsonBody = json.decode(raw);
      return RegistrationOptions.fromJson(jsonBody);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyToken);
  }
}
