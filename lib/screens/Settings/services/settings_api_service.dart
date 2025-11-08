import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/cache_service.dart';

class SettingsApiService {
  final String? baseUrl;
  final http.Client _client;

  SettingsApiService({String? baseUrl, http.Client? client}) 
      : baseUrl = baseUrl ?? "http://10.0.2.2:7777",
        _client = client ?? http.Client() {
    // baseUrl is now properly initialized in the initializer list
  }

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured for SettingsApiService');
    return Uri.parse(baseUrl! + path);
  }

  /// Set/Change Transaction PIN
  /// POST /personal-banking/users/set-pin
  /// Body: { "pin": "string" }
  /// Response: { "code": 0, "message": "string", "data": "string" }
  Future<Map<String, dynamic>> setPin(String pin) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'PIN set successfully'};
    }

    print('🔐 Setting PIN...');
    print('   URL: ${_uri('/personal-banking/users/set-pin')}');

    final res = await _client.post(
      _uri('/personal-banking/users/set-pin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getToken()}',
      },
      body: json.encode({'pin': pin}),
    );

    print('📥 Set PIN Response Status: ${res.statusCode}');
    print('📥 Set PIN Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'PIN set successfully';
          
          if (code == 0 || code == 200) {
            return {'success': true, 'message': message};
          } else {
            return {'success': false, 'message': message};
          }
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        return {'success': false, 'message': 'Invalid server response: $e'};
      }
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          return {'success': false, 'message': serverMsg.toString()};
        }
      }
    } catch (_) {}

    return {'success': false, 'message': 'Failed to set PIN (Status: ${res.statusCode})'};
  }

  /// Change Password
  /// POST /personal-banking/users/change-password
  /// Body: { "oldPassword": "string", "newPassword": "string" }
  /// Response: { "code": 0, "message": "string", "data": "string" }
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    print('🔐 SettingsApiService.changePassword called');
    print('🔐 baseUrl: $baseUrl');
    
    if (baseUrl == null) {
      print('⚠️ WARNING: baseUrl is null - using simulation mode!');
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Password changed successfully (SIMULATION)'};
    }

    print('🔐 Making real API call...');
    try {
      final token = await _getToken();
      final url = _uri('/personal-banking/users/change-password');
      final body = json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      print('🔐 Changing password...');
      print('   URL: $url');
      print('   Request Body: $body');
      print('   Token: ${token.substring(0, 20)}...');

      final res = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('📥 Change Password Response Status: ${res.statusCode}');
      print('📥 Change Password Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = json.decode(res.body);
          if (decoded is Map<String, dynamic>) {
            final code = decoded['code'];
            final message = decoded['message'] ?? 'Password changed successfully';
            
            if (code == 0 || code == 200) {
              print('✅ Password changed successfully: $message');
              return {'success': true, 'message': message};
            } else {
              print('❌ Password change failed: $message');
              return {'success': false, 'message': message};
            }
          }
        } catch (e) {
          print('❌ JSON parsing error: $e');
          return {'success': false, 'message': 'Invalid server response: $e'};
        }
      }

      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
          if (serverMsg != null) {
            print('❌ Server error: $serverMsg');
            return {'success': false, 'message': serverMsg.toString()};
          }
        }
      } catch (e) {
        print('❌ Error parsing error response: $e');
      }

      print('❌ Password change failed with status: ${res.statusCode}');
      return {'success': false, 'message': 'Failed to change password (Status: ${res.statusCode})'};
    } catch (e) {
      print('❌ Exception during password change: $e');
      if (e is SettingsApiException) rethrow;
      return {'success': false, 'message': 'Failed to change password: $e'};
    }
  }

  /// Helper to get token from cache
  Future<String> _getToken() async {
    final cache = CacheService();
    final token = await cache.getToken();
    if (token == null || token.accessToken.isEmpty) {
      throw SettingsApiException('No authentication token found');
    }
    return token.accessToken;
  }

  /// Auto Save Receipt
  /// PUT /personal-banking/users/autoSaveRecepit?flag=true
  /// Response: { "code": 0, "message": "string", "data": "string" }
  Future<Map<String, dynamic>> autoSaveReceipt(bool flag) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Receipt saved successfully'};
    }

    try {
      final token = await _getToken();
      final url = _uri('/personal-banking/users/autoSaveRecepit?flag=$flag');

      print('💾 Saving receipt...');
      print('   URL: $url');
      print('   Flag: $flag');

      final res = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Save Receipt Response Status: ${res.statusCode}');
      print('📥 Save Receipt Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = json.decode(res.body);
          if (decoded is Map<String, dynamic>) {
            final code = decoded['code'];
            final message = decoded['message'] ?? 'Receipt saved successfully';
            
            if (code == 0 || code == 200) {
              print('✅ Receipt saved successfully: $message');
              return {'success': true, 'message': message};
            } else {
              print('❌ Save receipt failed: $message');
              return {'success': false, 'message': message};
            }
          }
        } catch (e) {
          print('❌ JSON parsing error: $e');
          return {'success': false, 'message': 'Invalid server response: $e'};
        }
      }

      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
          if (serverMsg != null) {
            print('❌ Server error: $serverMsg');
            return {'success': false, 'message': serverMsg.toString()};
          }
        }
      } catch (e) {
        print('❌ Error parsing error response: $e');
      }

      print('❌ Save receipt failed with status: ${res.statusCode}');
      return {'success': false, 'message': 'Failed to save receipt (Status: ${res.statusCode})'};
    } catch (e) {
      print('❌ Exception during save receipt: $e');
      if (e is SettingsApiException) rethrow;
      return {'success': false, 'message': 'Failed to save receipt: $e'};
    }
  }

  void dispose() {
    _client.close();
  }
}

class SettingsApiException implements Exception {
  final String message;
  SettingsApiException(this.message);
  
  @override
  String toString() => 'SettingsApiException: $message';
}

