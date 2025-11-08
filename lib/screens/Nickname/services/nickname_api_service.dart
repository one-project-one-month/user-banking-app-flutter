import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/cache_service.dart';
import '../models/nickname.dart';

class NicknameApiService {
  final String? baseUrl;
  final http.Client _client;

  NicknameApiService({String? baseUrl, http.Client? client}) 
      : baseUrl = baseUrl ?? "http://10.0.2.2:7777",
        _client = client ?? http.Client() {
    // baseUrl is now properly initialized in the initializer list
  }

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured for NicknameApiService');
    return Uri.parse(baseUrl! + path);
  }


  /// Helper to get token from cache
  Future<String> _getToken() async {
    final cache = CacheService();
    final token = await cache.getToken();
    if (token == null || token.accessToken.isEmpty) {
      throw NicknameApiException('No authentication token found');
    }
    return token.accessToken;
  }

  Future<List<NicknameOption>> fetchNicknames() async {
    final token = await _getToken();
    final uri = _uri('/api/v1/nicknames');
    final res = await _client.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw NicknameApiException('Failed to fetch nicknames: ${res.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    final list = <NicknameOption>[];
    if (data != null && data['nicknameOptions'] != null) {
      final arr = data['nicknameOptions'] as List<dynamic>;
      for (final item in arr) {
        list.add(NicknameOption.fromJson(item as Map<String, dynamic>));
      }
    }
    return list;
  }

  Future<NicknameOption> createNickname({required String toaccountId, required String nickname}) async {
    final token = await _getToken();
    final uri = _uri('/api/v1/nicknames');
    final payload = json.encode({'toaccountId': toaccountId, 'nickname': nickname});
    final res = await _client.post(uri, body: payload, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw NicknameApiException('Failed to create nickname: ${res.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    if (data != null && data['nicknameOptions'] != null) {
      final arr = data['nicknameOptions'] as List<dynamic>;
      if (arr.isNotEmpty) return NicknameOption.fromJson(arr.first as Map<String, dynamic>);
    }
    throw NicknameApiException('Unexpected create response');
  }

  Future<NicknameOption> updateNickname({required String id, required String toaccountId, required String nickname}) async {
    final token = await _getToken();
    final uri = _uri('/api/v1/nicknames/$id');
    final payload = json.encode({'toaccountId': toaccountId, 'nickname': nickname});
    final res = await _client.put(uri, body: payload, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw NicknameApiException('Failed to update nickname: ${res.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    if (data != null && data['nicknameOptions'] != null) {
      final arr = data['nicknameOptions'] as List<dynamic>;
      if (arr.isNotEmpty) return NicknameOption.fromJson(arr.first as Map<String, dynamic>);
    }
    throw NicknameApiException('Unexpected update response');
  }

  Future<void> deleteNickname(String id) async {
    final token = await _getToken();
    final uri = _uri('/api/v1/nicknames/$id');
    final res = await _client.delete(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw NicknameApiException('Failed to delete nickname: ${res.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}

class NicknameApiException implements Exception {
  final String message;
  NicknameApiException(this.message);
  
  @override
  String toString() => 'NicknameApiException: $message';
}

