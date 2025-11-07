import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/token.dart';
import '../models/registration_options.dart';

class ApiService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;

  ApiService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured for ApiService');
    return Uri.parse(baseUrl! + path);
  }

  /// Request OTP to be sent to email
  /// POST /api/auth/register/email/verify
  /// Body: { "email": "user@example.com" }
  /// Response: { "code": 200, "message": "OTP sent successfully", "data": "430053" }
  Future<Map<String, dynamic>> requestOtp(String email) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Simulated OTP request', 'data': '123456'};
    }

    final res = await _client.post(
      _uri('/api/auth/register/email/verify'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    try {
      final decoded = json.decode(res.body);

      if (decoded is Map<String, dynamic>) {
        final code = decoded['code'];
        final message = decoded['message'] ?? 'Unknown response';
        final data = decoded['data'];

        if (res.statusCode >= 200 && res.statusCode < 300 && (code == 0 || code == 200)) {
          return {'success': true, 'message': message, 'data': data};
        } else {
          return {'success': false, 'message': message ?? 'Request failed'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Invalid server response: $e'};
    }

    return {'success': false, 'message': 'Unexpected error: ${res.reasonPhrase ?? res.statusCode}'};
  }

  /// Verify OTP code
  /// POST /api/auth/register/otp/verify
  /// Body: { "email": "user@example.com", "otp": "430053" }
  /// Response: { "verificationToken": "string" } OR { "data": { "verificationToken": "string" } }
  Future<String> verifyOtp(String email, String otp) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return 'sim_verification_token_${DateTime.now().millisecondsSinceEpoch}';
    }

    print('🔍 Verifying OTP:');
    print('   Email: $email');
    print('   OTP: $otp');
    print('   URL: ${_uri('/api/auth/register/otp/verify')}');

    final res = await _client.post(
      _uri('/api/auth/register/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    print('📥 Response Status: ${res.statusCode}');
    print('📥 Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          String? token;

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              token = data['verificationToken'] ?? data['verification_token'] ?? data['token'];
            } else if (data is String) {
              token = data;
            }
          }

          if (token == null) {
            token = decoded['verificationToken'] ?? decoded['verification_token'] ?? decoded['token'];
          }

          if (token != null && token.isNotEmpty) {
            print('✅ Token found: ${token.substring(0, 10)}...');
            return token;
          }

          print('❌ Token not found in response: $decoded');
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
      }

      throw HttpException('Invalid response: verificationToken not found', uri: _uri('/api/auth/register/otp/verify'));
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'] ?? decoded['msg'];

        if (serverMsg != null) {
          print('❌ Server error: $serverMsg');
          throw HttpException('OTP verification failed: $serverMsg', uri: _uri('/api/auth/register/otp/verify'));
        }
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      print('❌ Error parsing error response: $e');
    }

    throw HttpException(
      'OTP verification failed (Status: ${res.statusCode}, Body: ${res.body})',
      uri: _uri('/api/auth/register/otp/verify'),
    );
  }

  /// Submit personal details (final registration step)
  /// POST /api/auth/register/personal-details
  Future<Map<String, dynamic>> submitPersonalDetails({
    required String verificationToken,
    required String fullname,
    required String dateOfBirth,
    required int genderId,
    required int nationalityId,
    required String kycType,
    required String kycData,
  }) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'accessToken': 'sim_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'sim_refresh_token',
        'email': 'test@example.com',
        'username': fullname,
        'currentBalance': 0,
      };
    }

    final res = await _client.post(
      _uri('/api/auth/register/personal-details'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'verificationToken': verificationToken,
        'fullname': fullname,
        'dateOfBirth': dateOfBirth,
        'genderId': genderId,
        'nationalityId': nationalityId,
        'kycType': kycType,
        'kycData': kycData,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return decoded;
      }
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException('Registration failed: $serverMsg', uri: _uri('/api/auth/register/personal-details'));
        }
      }
    } catch (_) {}

    throw HttpException('Registration failed', uri: _uri('/api/auth/register/personal-details'));
  }

  /// Login with credentials and get full user data
  /// POST /api/auth/login
  /// Body: { "username": "string", "password": "string" }
  Future<Map<String, dynamic>> loginAndGetUserData(String username, String password) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'accessToken': 'sim_access_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'sim_refresh',
        'email': 'user@example.com',
        'username': username,
        'currentBalance': 1000,
      };
    }

    final res = await _client.post(
      _uri('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    print('🔐 Login Response Status: ${res.statusCode}');
    print('🔐 Login Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);

      if (decoded is Map<String, dynamic>) {
        final code = decoded['code'];
        if (code != null && code != 0 && code != 200) {
          final message = decoded['message'] ?? 'Login failed';
          throw HttpException('Login failed: $message', uri: _uri('/api/auth/login'));
        }

        if (decoded.containsKey('data')) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            print('✅ Login successful! User: ${data['username']}, Balance: ${data['currentBalance']}');
            return data;
          }
        }

        if (decoded.containsKey('accessToken') || decoded.containsKey('access_token')) {
          return decoded;
        }
      }
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException('Login failed: $serverMsg', uri: _uri('/api/auth/login'));
        }
      }
    } catch (e) {
      if (e is HttpException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw HttpException('Login failed: $fallback', uri: _uri('/api/auth/login'));
  }

  /// Login with credentials (legacy - returns Token only)
  Future<Token> login(String username, String password) async {
    final data = await loginAndGetUserData(username, password);
    return Token.fromJson(data);
  }

  /// Create password
  Future<bool> createPassword(String password) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }

    final res = await _client.post(
      _uri('/api/auth/create-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return true;

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException('Create password failed: $serverMsg', uri: _uri('/api/auth/create-password'));
        }
      }
    } catch (_) {}

    throw HttpException('Create password failed', uri: _uri('/api/auth/create-password'));
  }

  /// Fetch registration template
  Future<RegistrationOptions> fetchRegistrationOptions() async {
    if (baseUrl == null) {
      return RegistrationOptions.empty();
    }

    final res = await _client.get(_uri('/api/auth/register/personal-details/template'));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);

      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return RegistrationOptions.fromJson(data);
        }
      }

      if (decoded is Map<String, dynamic>) {
        return RegistrationOptions.fromJson(decoded);
      }
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw HttpException(
            'Fetch template failed: $serverMsg',
            uri: _uri('/api/auth/register/personal-details/template'),
          );
        }
      }
    } catch (_) {}

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw HttpException('Fetch template failed: $fallback', uri: _uri('/api/auth/register/personal-details/template'));
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
  String toString() => 'HttpException: $message ${uri != null ? "(url: $uri)" : ''}';
}
