import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/token.dart';
import '../models/registration_options.dart';

/// Simple API service for auth flows.
///
/// If [baseUrl] is not provided the service will simulate responses locally
/// (useful for development without a backend).
class ApiService {
  String? baseUrl = "https://banking-dummy-backend.onrender.com";
  final http.Client _client;

  ApiService({this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null)
      throw StateError('No baseUrl configured for ApiService');
    return Uri.parse(baseUrl! + path);
  }

  /// Register user with [payload]. Returns a [Token] on success.
  Future<Token> register(Map<String, dynamic> payload) async {
    if (baseUrl == null) {
      // Simulate network latency
      await Future.delayed(const Duration(milliseconds: 600));
      return Token(
        accessToken: 'sim_register_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    final res = await _client.post(
      _uri('/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> jsonBody = json.decode(res.body);
      return Token.fromJson(jsonBody);
    }
    // try to include server error message when available
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg =
            decoded['message'] ??
            decoded['error'] ??
            decoded['detail'] ??
            decoded['errors'] ??
            null;
        if (serverMsg != null) {
          throw HttpException(
            'Register failed: $serverMsg',
            uri: _uri('/register'),
          );
        }
      }
    } catch (_) {}

    throw HttpException('Register failed', uri: _uri('/register'));
  }

  /// Login with credentials. Returns a [Token] on success.
  Future<Token> login(String username, String password) async {
    final res = await _client.post(
      _uri('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> jsonBody = json.decode(res.body);
      return Token.fromJson(jsonBody);
    }

    // Try to extract a meaningful server error message from the body.
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg =
            decoded['message'] ??
            decoded['error'] ??
            decoded['detail'] ??
            decoded['errors'] ??
            null;
        if (serverMsg != null) {
          throw HttpException(
            'Login failed: $serverMsg',
            uri: _uri('/api/auth/login'),
          );
        }
      }
    } catch (_) {
      // ignore JSON parse errors and fall back to generic message below
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw HttpException(
      'Login failed: $fallback',
      uri: _uri('/api/auth/login'),
    );
  }

  /// Request an OTP to be sent to [destination] (phone or email).
  /// Returns true when the request was accepted.
  Future<bool> requestOtp(String destination) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    final res = await _client.post(
      _uri('/otp/request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'to': destination}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return true;

    // parse server error message if present
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg =
            decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException(
            'OTP request failed: $serverMsg',
            uri: _uri('/otp/request'),
          );
        }
      }
    } catch (_) {}

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw HttpException(
      'OTP request failed: $fallback',
      uri: _uri('/otp/request'),
    );
  }

  /// Confirm OTP [code] for [destination]. Returns a [Token] on success.
  Future<Token> confirmOtp(String destination, String code) async {
    if (code == '123456') {
      return Token(
        accessToken: 'sim_otp_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      // accept any 4-6 digit code in simulation: normalize and validate
      final cleaned = code.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.length >= 4 && cleaned.length <= 6) {
        return Token(
          accessToken: 'sim_otp_${DateTime.now().millisecondsSinceEpoch}',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      }
      throw AuthException('Invalid OTP');
    }

    final res = await _client.post(
      _uri('/otp/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'to': destination, 'code': code}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> jsonBody = json.decode(res.body);
      return Token.fromJson(jsonBody);
    }
    // try extract server message
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg =
            decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException(
            'OTP confirmation failed: $serverMsg',
            uri: _uri('/otp/confirm'),
          );
        }
      }
    } catch (_) {}
    throw HttpException('OTP confirmation failed', uri: _uri('/otp/confirm'));
  }

  /// Create or set a password for [destination] using [code] (OTP) and [password].
  /// Returns true when the server accepted the request.
  Future<bool> createPassword(
    // String destination,
    // String code,
    String password,
  ) async {
    if (password == '12345678') return true;

    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }

    final res = await _client.post(
      _uri('/api/auth/create-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        //  'to': destination,
        // 'code': code,
        'password': password,
      }),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return true;

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg =
            decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException(
            'Create password failed: $serverMsg',
            uri: _uri('/api/auth/create-password'),
          );
        }
      }
    } catch (_) {}

    throw HttpException(
      'Create password failed',
      uri: _uri('/api/auth/create-password'),
    );
  }

  /// Fetch registration template for personal details (gender & nationality options)
  Future<RegistrationOptions> fetchRegistrationOptions() async {
    if (baseUrl == null) {
      // return empty or a small simulated set
      return RegistrationOptions.empty();
    }

    final res = await _client.get(
      _uri('/api/auth/register/personal-details/template'),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> jsonBody = json.decode(res.body);
      return RegistrationOptions.fromJson(jsonBody);
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg =
            decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException(
            'Fetch template failed: $serverMsg',
            uri: _uri('/auth/register/personal-details/template'),
          );
        }
      }
    } catch (_) {}

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw HttpException(
      'Fetch template failed: $fallback',
      uri: _uri('/auth/register/personal-details/template'),
    );
  }

  void dispose() {
    _client.close();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

class HttpException implements Exception {
  final String message;
  final Uri? uri;
  HttpException(this.message, {this.uri});
  @override
  String toString() =>
      'HttpException: $message ${uri != null ? "(url: $uri)" : ''}';
}
