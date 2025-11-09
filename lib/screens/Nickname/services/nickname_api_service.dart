import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/cache_service.dart';
import '../models/nickname.dart';

class NicknameApiService {
  final String? baseUrl;
  final http.Client _client;

  NicknameApiService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? "http://10.0.2.2:7777",
      _client = client ?? http.Client();

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

  /// NEW METHOD: Verify account number and get account ID
  /// POST /personal-banking/transfer/to-account-number/prepare
  /// Body: { "toAccountNumber": "string" }
  /// Returns: account ID from the response
  Future<String> getAccountIdByNumber(String accountNumber) async {
    final token = await _getToken();

    // Try multiple endpoint variations
    final candidatePaths = [
      '/personal-banking/transfer/to-account-number/prepare',
      '/personal-banking/transfer/account-number/prepare',
    ];

    for (final path in candidatePaths) {
      try {
        print('🔍 Verifying account number: $accountNumber on $path');

        final res = await _client.post(
          _uri(path),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: json.encode({'toAccountNumber': accountNumber}),
        );

        print('📥 Verify Response Status: ${res.statusCode}');
        print('📥 Verify Response Body: ${res.body}');

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final Map<String, dynamic> body = json.decode(res.body);
          final code = body['code'];

          if (code == 0 || code == 200) {
            final data = body['data'];
            if (data is Map<String, dynamic>) {
              // Try to extract account ID from response
              final toAcc = data['toAccountDetails'] ?? data['to_account_details'] ?? data['accountDetails'];

              if (toAcc is Map<String, dynamic>) {
                final accountId = toAcc['id']?.toString();
                if (accountId != null && accountId.isNotEmpty) {
                  print('✅ Found account ID: $accountId for account number: $accountNumber');
                  return accountId;
                }
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ Failed to verify on $path: $e');
        continue;
      }
    }

    throw NicknameApiException('Could not find account ID for account number: $accountNumber');
  }

  /// GET /personal-banking/users/nickname
  Future<List<NicknameOption>> fetchNicknames() async {
    final token = await _getToken();
    final uri = _uri('/personal-banking/users/nickname');

    print('📋 Fetching nicknames from: $uri');

    final res = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    print('📥 Fetch Response Status: ${res.statusCode}');
    print('📥 Fetch Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
        final code = body['code'];

        if (code == 0 || code == 200) {
          final data = body['data'] as Map<String, dynamic>?;
          final list = <NicknameOption>[];

          if (data != null && data['nicknameOptions'] != null) {
            final arr = data['nicknameOptions'] as List<dynamic>;
            for (final item in arr) {
              list.add(NicknameOption.fromJson(item as Map<String, dynamic>));
            }
          }

          print('✅ Fetched ${list.length} nicknames');
          return list;
        } else {
          final message = body['message'] ?? 'Failed to fetch nicknames';
          throw NicknameApiException(message);
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        throw NicknameApiException('Failed to parse response: $e');
      }
    }

    throw NicknameApiException('Failed to fetch nicknames: ${res.statusCode}');
  }

  /// POST /personal-banking/users/nickname
  /// Body: { "toAccountId": "string" (numeric ID), "nickname": "string" }
  Future<NicknameOption> createNickname({required String toAccountId, required String nickname}) async {
    final token = await _getToken();
    final uri = _uri('/personal-banking/users/nickname');

    // Convert toAccountId to int if possible, keep as string otherwise
    final accountIdValue = int.tryParse(toAccountId) ?? toAccountId;

    final payload = json.encode({'toAccountId': accountIdValue, 'nickname': nickname});

    print('📝 Creating nickname at: $uri');
    print('📝 Payload: $payload');

    final res = await _client.post(
      uri,
      body: payload,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    print('📥 Create Response Status: ${res.statusCode}');
    print('📥 Create Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
        final code = body['code'];

        if (code == 0 || code == 200) {
          print('✅ Nickname created successfully');
          return NicknameOption(
            id: '',
            nickname: nickname,
            toaccountDetail: ToAccountDetail(id: toAccountId, accountNumber: toAccountId),
          );
        } else {
          final message = body['message'] ?? 'Failed to create nickname';
          throw NicknameApiException(message);
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        throw NicknameApiException('Failed to parse response: $e');
      }
    }

    throw NicknameApiException('Failed to create nickname: ${res.statusCode}');
  }

  /// PUT /personal-banking/users/nickname/{nicknameId}
  Future<NicknameOption> updateNickname({
    required String id,
    required String toAccountId,
    required String nickname,
  }) async {
    final token = await _getToken();
    final uri = _uri('/personal-banking/users/nickname/$id');

    final accountIdValue = int.tryParse(toAccountId) ?? toAccountId;

    final payload = json.encode({'toAccountId': accountIdValue, 'nickname': nickname});

    print('✏️ Updating nickname at: $uri');
    print('✏️ Payload: $payload');

    final res = await _client.put(
      uri,
      body: payload,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    print('📥 Update Response Status: ${res.statusCode}');
    print('📥 Update Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
        final code = body['code'];

        if (code == 0 || code == 200) {
          print('✅ Nickname updated successfully');
          return NicknameOption(
            id: id,
            nickname: nickname,
            toaccountDetail: ToAccountDetail(id: toAccountId, accountNumber: toAccountId),
          );
        } else {
          final message = body['message'] ?? 'Failed to update nickname';
          throw NicknameApiException(message);
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        throw NicknameApiException('Failed to parse response: $e');
      }
    }

    try {
      final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
      final message = body['message'] ?? 'Unknown error';
      throw NicknameApiException('Update failed (${res.statusCode}): $message');
    } catch (e) {
      if (e is NicknameApiException) rethrow;
      throw NicknameApiException('Failed to update nickname: ${res.statusCode}');
    }
  }

  /// DELETE /personal-banking/users/nickname/{nicknameId}
  Future<void> deleteNickname(String id) async {
    final token = await _getToken();
    final uri = _uri('/personal-banking/users/nickname/$id');

    print('🗑️ Deleting nickname at: $uri');

    final res = await _client.delete(
      uri,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    print('📥 Delete Response Status: ${res.statusCode}');
    print('📥 Delete Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
        final code = body['code'];

        if (code == 0 || code == 200) {
          print('✅ Nickname deleted successfully');
          return;
        } else {
          final message = body['message'] ?? 'Failed to delete nickname';
          throw NicknameApiException(message);
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        if (res.statusCode == 200 || res.statusCode == 204) {
          print('✅ Nickname deleted (empty response)');
          return;
        }
        throw NicknameApiException('Failed to parse response: $e');
      }
    }

    throw NicknameApiException('Failed to delete nickname: ${res.statusCode}');
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
