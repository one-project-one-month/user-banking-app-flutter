import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsApiService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;

  SettingsApiService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Auto Save Receipt
  /// PUT /personal-banking/users/autoSaveReceipt?flag=true|false
  /// Headers: Authorization: Bearer {token}
  /// Response: { "code": 200, "message": "Preference updated", "data": null }
  Future<Map<String, dynamic>> setAutoSaveReceipt(String accessToken, bool enabled) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Receipt auto-save ${enabled ? 'enabled' : 'disabled'} successfully'};
    }

    print('📋 Setting auto-save receipt to: $enabled');
    print('   URL: ${_uri('/personal-banking/users/autoSaveReceipt?flag=$enabled')}');

    final res = await _client.put(
      _uri('/personal-banking/users/autoSaveReceipt?flag=$enabled'),
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
