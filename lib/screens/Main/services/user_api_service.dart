import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserApiService {
  String? baseUrl = "https://136.112.160.13:7777";
  final http.Client _client;

  UserApiService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured for UserApiService');
    return Uri.parse(baseUrl! + path);
  }

  /// Get current user info
  /// GET /personal-banking/users/me
  /// Headers: Authorization: Bearer {token}
  /// Response: {
  ///   "code": 0,
  ///   "message": "string",
  ///   "data": {
  ///     "email": "string",
  ///     "username": "string",
  ///     "currentBalance": 0
  ///   }
  /// }
  Future<User> getCurrentUser(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return User(email: 'demo@example.com', username: 'DemoUser', currentBalance: 5000000.0);
    }

    print('🔍 Fetching user data...');
    print('   URL: ${_uri('/personal-banking/users/me')}');
    print('   Token: ${accessToken.substring(0, 20)}...');

    final res = await _client.get(
      _uri('/personal-banking/users/me'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    );

    print('📥 User Data Response Status: ${res.statusCode}');
    print('📥 User Data Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          // Check for code field (0 or 200 = success)
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to fetch user data';
            throw UserApiException(message);
          }

          // Extract data
          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              print('✅ User data loaded: ${data['username']}, Balance: ${data['currentBalance']}');
              return User.fromJson(data);
            }
          }

          // Handle direct response (no wrapper)
          if (decoded.containsKey('username') || decoded.containsKey('email')) {
            return User.fromJson(decoded);
          }
        }
      } catch (e) {
        if (e is UserApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw UserApiException('Invalid response format: $e');
      }
    }

    // Handle error responses
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw UserApiException('Failed to fetch user: $serverMsg');
        }
      }
    } catch (e) {
      if (e is UserApiException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw UserApiException('Failed to fetch user data: $fallback');
  }

  void dispose() {
    _client.close();
  }
}

class UserApiException implements Exception {
  final String message;
  UserApiException(this.message);

  @override
  String toString() => 'UserApiException: $message';
}
