import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsApiService {
  String? baseUrl = "https://136.112.160.13:7777"; // Updated to HTTPS server
  final http.Client _client;

  SettingsApiService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Get Auto Save Receipt setting
  /// GET /personal-banking/users/autoSaveRecepit
  /// Headers: Authorization: Bearer {token}
  /// Response: { "code": 200, "message": "...", "data": { "flag": true/false } }
  Future<bool?> getAutoSaveReceipt(String accessToken) async {
    if (baseUrl == null) {
      return false; // Default to false if no baseUrl
    }

    print('📋 Fetching auto-save receipt setting');
    print('   URL: ${_uri('/personal-banking/users/autoSaveRecepit')}');

    try {
      final res = await _client.get(
        _uri('/personal-banking/users/autoSaveRecepit'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
      );

      print('📥 Get Auto Save Receipt Response Status: ${res.statusCode}');
      print('📥 Get Auto Save Receipt Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = json.decode(res.body);
          if (decoded is Map<String, dynamic>) {
            final code = decoded['code'];
            if (code == 0 || code == 200) {
              final data = decoded['data'];

              // Handle different response formats
              bool? flag;
              if (data is Map<String, dynamic>) {
                // If data is an object, look for 'flag' property
                flag = data['flag'] as bool?;
              } else if (data is bool) {
                // If data is directly a boolean
                flag = data;
              } else if (data is String) {
                // If data is a string, try to parse it
                flag = data.toLowerCase() == 'true';
              }

              if (flag != null) {
                print('✅ Auto-save receipt setting: $flag');
                return flag;
              } else {
                print('⚠️ Could not extract flag from response data: $data');
              }
            }
          }
        } catch (e) {
          print('❌ JSON parsing error: $e');
        }
      }
    } catch (e) {
      print('❌ Error fetching auto-save receipt: $e');
    }

    return null; // Return null if failed to fetch
  }

  /// Auto Save Receipt
  /// PUT /personal-banking/users/autoSaveRecepit?flag=true|false
  /// Headers: Authorization: Bearer {token}
  /// Response: { "code": 200, "message": "Preference updated", "data": null }
  Future<Map<String, dynamic>> setAutoSaveReceipt(String accessToken, bool enabled) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Receipt auto-save ${enabled ? 'enabled' : 'disabled'} successfully'};
    }

    print('📋 Setting auto-save receipt to: $enabled');
    print('   URL: ${_uri('/personal-banking/users/autoSaveRecepit?flag=$enabled')}');

    final res = await _client.put(
      _uri('/personal-banking/users/autoSaveRecepit?flag=$enabled'), // Fixed typo: Recepit
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
    );

    print('📥 Auto Save Receipt Response Status: ${res.statusCode}');
    print('📥 Auto Save Receipt Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'Preference updated';

          if (code == 0 || code == 200) {
            print('✅ Auto-save receipt updated successfully: $message');
            return {'success': true, 'message': message};
          } else {
            print('❌ Auto-save receipt update failed: $message');
            return {'success': false, 'message': message};
          }
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        // If response is empty or not JSON, consider it success for 2xx status
        if (res.statusCode == 200 || res.statusCode == 204) {
          return {'success': true, 'message': 'Receipt auto-save ${enabled ? 'enabled' : 'disabled'} successfully'};
        }
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
    } catch (_) {}

    print('❌ Auto-save receipt update failed with status: ${res.statusCode}');
    return {'success': false, 'message': 'Failed to update auto-save preference (Status: ${res.statusCode})'};
  }

  /// Set Transaction PIN
  /// POST /personal-banking/users/set-pin
  /// Body: { "pin": "string" }
  /// Headers: Authorization: Bearer {token}
  /// Response: { "code": 200, "message": "PIN set successfully", "data": null }
Future<Map<String, dynamic>> setPin(String accessToken, String pin) async {
  if (baseUrl == null) {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'message': 'PIN set successfully'};
  }

  print('📋 Setting transaction PIN...');
  print('   URL: ${_uri('/personal-banking/users/set-pin')}');

  final res = await _client.post(
    _uri('/personal-banking/users/set-pin'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Accept': '*/*',
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
          print('✅ PIN set successfully: $message');
          return {'success': true, 'message': message, 'data': decoded['data']};
        } else {
          print('❌ Set PIN failed: $message');
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
  } catch (_) {}

  print('❌ Set PIN failed with status: ${res.statusCode}');
  return {'success': false, 'message': 'Failed to set PIN (Status: ${res.statusCode})'};
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
