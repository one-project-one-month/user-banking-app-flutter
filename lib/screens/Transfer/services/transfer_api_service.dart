import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_models.dart';

class TransferApiService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;

  TransferApiService({this.baseUrl, http.Client? client}) 
      : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Get user's from accounts or selected account
  /// Preferred: GET /personal-banking/users/me (contains selectedAccountDetails)
  /// Legacy: GET /personal-banking/users/from-accounts (contains fromAccountOptions)
  /// Headers: Authorization: Bearer {token}
  /// Response: {
  ///   "code": 0,
  ///   "message": "string",
  ///   "data": {
  ///     "fromAccountOptions": [
  ///       {
  ///         "id": 0,
  ///         "accountNumber": "string",
  ///         "balance": 0
  ///       }
  ///     ]
  ///   }
  /// }
  Future<List<FromAccount>> getFromAccounts(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        FromAccount(id: '1', accountNumber: '234-1-56643-6', balance: 588000),
      ];
    }

    // Try the user profile endpoint first (richer response)
    print('🔍 Fetching user profile for accounts...');
    print('   URL: ${_uri('/personal-banking/users/me')}');

    http.Response res = await _client.get(
      _uri('/personal-banking/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('📥 Users/Me Response Status: ${res.statusCode}');
    print('📥 Users/Me Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to fetch accounts';
            throw TransferApiException(message);
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              // 1) Legacy list key variations
              final listA = data['fromAccountOptions'];
              final listB = data['fromAccountsOptions'];
              final dynamic accountsList = listA ?? listB;
              if (accountsList is List) {
                return accountsList
                    .map((acc) => FromAccount.fromJson(Map<String, dynamic>.from(acc)))
                    .toList();
              }

              // 2) Selected account details (single)
              final selected = data['selectedAccountDetails'];
              if (selected is Map) {
                return [FromAccount.fromJson(Map<String, dynamic>.from(selected))];
              }
            }
          }
        }
      } catch (e) {
        if (e is TransferApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw TransferApiException('Invalid response format: $e');
      }
    }

    // Fallback to the legacy endpoint only if /me fails
    print('ℹ️ Falling back to legacy from-accounts endpoint');
    res = await _client.get(
      _uri('/personal-banking/users/from-accounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            final listA = data['fromAccountOptions'];
            final listB = data['fromAccountsOptions'];
            final dynamic accountsList = listA ?? listB;
            if (accountsList is List) {
              return accountsList
                  .map((acc) => FromAccount.fromJson(Map<String, dynamic>.from(acc)))
                  .toList();
            }
          }
        }
      } catch (_) {}
    }

    throw TransferApiException('Failed to fetch accounts');
  }

  /// Prepare transfer by getting recipient details
  /// POST /personal-banking/transfer/nickname/prepare
  /// Body: { "nicknameId": 0 }
  /// Headers: Authorization: Bearer {token}
  /// Response: {
  ///   "code": 0,
  ///   "message": "string",
  ///   "data": {
  ///     "authDetails": {
  ///       "id": 0,
  ///       "accountNumber": "string"
  ///     },
  ///     "userDetails": {
  ///       "id": 0,
  ///       "fullName": "string"
  ///     }
  ///   }
  /// }
  Future<TransferRecipient> prepareTransferByNickname(
    String accessToken,
    String nicknameId,
  ) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TransferRecipient(
        id: nicknameId,
        accountNumber: '00123456789',
        fullName: 'Mrs. Christine',
      );
    }

    print('🔍 Preparing transfer for nickname: $nicknameId');

    final res = await _client.post(
      _uri('/personal-banking/transfer/nickname/prepare'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'nicknameId': int.tryParse(nicknameId) ?? 0}),
    );

    print('📥 Prepare Transfer Response Status: ${res.statusCode}');
    print('📥 Prepare Transfer Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to prepare transfer';
            throw TransferApiException(message);
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              final authDetails = data['authDetails'] as Map<String, dynamic>?;
              final userDetails = data['userDetails'] as Map<String, dynamic>?;

              return TransferRecipient(
                id: authDetails?['id']?.toString() ?? '',
                accountNumber: authDetails?['accountNumber'] ?? '',
                fullName: userDetails?['fullName'] ?? userDetails?['fullname'] ?? '',
              );
            }
          }
        }
      } catch (e) {
        if (e is TransferApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw TransferApiException('Invalid response format: $e');
      }
    }

    throw TransferApiException('Failed to prepare transfer');
  }

  /// Prepare transfer by destination account number
  /// POST /personal-banking/transfer/account-number/prepare
  /// Body: { "toAccountNumber": "string" }
  /// Response data contains { toAccountDetails: {id, accountNumber}, userDetails: {id, fullName/fullname} }
  Future<TransferRecipient> prepareTransferByAccountNumber(
    String accessToken,
    String toAccountNumber,
  ) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TransferRecipient(id: 'sim', accountNumber: toAccountNumber, fullName: 'Simulated User');
    }

    final candidatePaths = <String>[
      // Provided endpoint
      '/personal-banking/transfer/to-account-number/prepare',
      // Reasonable alternates we try if backend differs
      '/personal-banking/transfer/account-number/prepare',
      '/personal-banking/transfers/account-number/prepare',
      '/personal-banking/transfer/to-account/prepare',
    ];

    for (final path in candidatePaths) {
      print('🔍 Verifying toAccountNumber on $path');
      final res = await _client.post(
        _uri(path),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'toAccountNumber': toAccountNumber}),
      );

      print('📥 Prepare-by-account Response ${res.statusCode}: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = json.decode(res.body);
          if (decoded is Map<String, dynamic>) {
            final code = decoded['code'];
            if (code != null && code != 0 && code != 200) {
              final message = decoded['message'] ?? 'Failed to prepare transfer';
              throw TransferApiException(message);
            }

            final data = decoded['data'] ?? decoded['result'];
            if (data is Map<String, dynamic>) {
              final toAcc = (data['toAccountDetails'] ?? data['to_account_details'] ?? data['accountDetails']) as Map?;
              final user = (data['userDetails'] ?? data['user_details'] ?? data['recipientDetails']) as Map?;
              return TransferRecipient(
                id: toAcc != null ? (toAcc['id']?.toString() ?? '') : '',
                accountNumber: toAcc != null ? (toAcc['accountNumber'] ?? toAcc['account_number'] ?? toAccountNumber) : toAccountNumber,
                fullName: user != null ? (user['fullName'] ?? user['fullname'] ?? user['name'] ?? '') : '',
              );
            }
          }
        } catch (e) {
          if (e is TransferApiException) rethrow;
        }
      } else {
        // Try next path on non-2xx
        continue;
      }
    }

    throw TransferApiException('Failed to verify account number');
  }

  void dispose() {
    _client.close();
  }
}

class TransferApiException implements Exception {
  final String message;
  TransferApiException(this.message);
  
  @override
  String toString() => 'TransferApiException: $message';
}