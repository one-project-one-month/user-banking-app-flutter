import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_models.dart';

class TransferApiService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;

  TransferApiService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// NEW METHOD: Fetch nicknames from API
  /// GET /personal-banking/users/nickname
  /// Response: {
  ///   "code": 0,
  ///   "message": "string",
  ///   "data": {
  ///     "nicknameOptions": [
  ///       {
  ///         "id": 0,
  ///         "nickname": "string",
  ///         "toAccountDetail": {
  ///           "id": 0,
  ///           "accountNumber": "string"
  ///         }
  ///       }
  ///     ]
  ///   }
  /// }
  Future<List<FavoriteUser>> fetchNicknames(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        FavoriteUser(nicknameId: '1', nickname: 'Mom', accountNumber: '00123456789', fullName: 'Mrs. Christine'),
        FavoriteUser(nicknameId: '2', nickname: 'Dad', accountNumber: '00198765432', fullName: 'Mr. John Doe'),
      ];
    }

    print('📋 Fetching nicknames...');
    print('   URL: ${_uri('/personal-banking/users/nickname')}');

    final res = await _client.get(
      _uri('/personal-banking/users/nickname'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    );

    print('📥 Fetch Nicknames Response Status: ${res.statusCode}');
    print('📥 Fetch Nicknames Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to fetch nicknames';
            throw TransferApiException(message);
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic> && data.containsKey('nicknameOptions')) {
              final nicknamesList = data['nicknameOptions'];
              if (nicknamesList is List) {
                print('✅ Found ${nicknamesList.length} nicknames');
                return nicknamesList.map((item) {
                  final itemMap = item as Map<String, dynamic>;
                  final toAccountDetail = itemMap['toAccountDetail'] as Map<String, dynamic>?;

                  return FavoriteUser(
                    nicknameId: itemMap['id']?.toString() ?? '',
                    nickname: itemMap['nickname']?.toString() ?? '',
                    accountNumber: toAccountDetail?['accountNumber']?.toString() ?? '',
                    fullName: '', // Will be filled by prepare endpoint
                  );
                }).toList();
              }
            }
          }
        }

        print('⚠️ Unexpected response format, returning empty list');
        return [];
      } catch (e) {
        if (e is TransferApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw TransferApiException('Invalid response format: $e');
      }
    }

    // Handle error responses
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw TransferApiException('Failed to fetch nicknames: $serverMsg');
        }
      }
    } catch (e) {
      if (e is TransferApiException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw TransferApiException('Failed to fetch nicknames: $fallback');
  }

  /// Get user's from accounts or selected account
  Future<List<FromAccount>> getFromAccounts(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return [FromAccount(id: '3', accountNumber: '1000000002', balance: 75000)];
    }

    print('📋 Fetching user profile for accounts...');
    print('   URL: ${_uri('/personal-banking/users/me')}');

    http.Response res = await _client.get(
      _uri('/personal-banking/users/me'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
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
              // Legacy list key variations
              final listA = data['fromAccountOptions'];
              final listB = data['fromAccountsOptions'];
              final dynamic accountsList = listA ?? listB;
              if (accountsList is List) {
                return accountsList.map((acc) => FromAccount.fromJson(Map<String, dynamic>.from(acc))).toList();
              }

              // Selected account details (single)
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

    throw TransferApiException('Failed to fetch accounts');
  }

  /// Prepare transfer by nickname
  Future<TransferRecipient> prepareTransferByNickname(String accessToken, String nicknameId) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TransferRecipient(id: '2', accountNumber: '1000000001', fullName: 'System Administrator');
    }

    print('📋 Preparing transfer for nickname: $nicknameId');

    final res = await _client.post(
      _uri('/personal-banking/transfer/nickname/prepare'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
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
              final toAccDetails = data['toAccountDetails'] as Map<String, dynamic>?;
              final userDetails = data['userDetails'] as Map<String, dynamic>?;

              return TransferRecipient(
                id: toAccDetails?['id']?.toString() ?? '',
                accountNumber: toAccDetails?['accountNumber'] ?? '',
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

  /// Prepare transfer by account number
  Future<TransferRecipient> prepareTransferByAccountNumber(String accessToken, String toAccountNumber) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TransferRecipient(id: '2', accountNumber: toAccountNumber, fullName: 'System Administrator');
    }

    final candidatePaths = <String>[
      '/personal-banking/transfer/to-account-number/prepare',
      '/personal-banking/transfer/account-number/prepare',
    ];

    for (final path in candidatePaths) {
      print('📋 Verifying toAccountNumber on $path');
      final res = await _client.post(
        _uri(path),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
        body: json.encode({'toAccountNumber': toAccountNumber}),
      );

      print('📥 Prepare-by-account Response ${res.statusCode}: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = json.decode(res.body);
          if (decoded is Map<String, dynamic>) {
            final code = decoded['code'];
            if (code != null && code != 0 && code != 200) {
              continue;
            }

            final data = decoded['data'] ?? decoded['result'];
            if (data is Map<String, dynamic>) {
              final toAcc = (data['toAccountDetails'] ?? data['to_account_details'] ?? data['accountDetails']) as Map?;
              final user = (data['userDetails'] ?? data['user_details'] ?? data['recipientDetails']) as Map?;
              return TransferRecipient(
                id: toAcc != null ? (toAcc['id']?.toString() ?? '') : '',
                accountNumber:
                    toAcc != null
                        ? (toAcc['accountNumber'] ?? toAcc['account_number'] ?? toAccountNumber)
                        : toAccountNumber,
                fullName: user != null ? (user['fullName'] ?? user['fullname'] ?? user['name'] ?? '') : '',
              );
            }
          }
        } catch (e) {
          if (e is TransferApiException) rethrow;
        }
      }
    }

    throw TransferApiException('Failed to verify account number');
  }

  /// Validate Transfer
  Future<Map<String, dynamic>> validateTransfer(String accessToken, int toAccountId) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'success': true,
        'message': 'Transfer validated successfully',
        'data': {
          'fromAccountDetails': {'id': 3, 'accountNumber': '1000000002', 'balance': 75000},
          'toAccountDetails': {'id': 2, 'accountNumber': '1000000001', 'balance': 50000},
        },
      };
    }

    print('📋 Validating transfer...');
    print('   URL: ${_uri('/personal-banking/transfer/validate')}');
    print('   toAccountId: $toAccountId');

    final res = await _client.post(
      _uri('/personal-banking/transfer/validate'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
      body: json.encode({'toAccountId': toAccountId}),
    );

    print('📥 Validate Transfer Response Status: ${res.statusCode}');
    print('📥 Validate Transfer Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'Transfer validated successfully';

          if (code == 0 || code == 200) {
            print('✅ Transfer validated successfully: $message');
            return {'success': true, 'message': message, 'data': decoded['data'] ?? decoded};
          } else {
            print('❌ Transfer validation failed: $message');
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

    print('❌ Transfer validation failed with status: ${res.statusCode}');
    return {'success': false, 'message': 'Failed to validate transfer (Status: ${res.statusCode})'};
  }

  /// Verify Transaction PIN
  Future<Map<String, dynamic>> verifyPin(String accessToken, String pin) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'PIN verified successfully'};
    }

    print('📋 Verifying PIN...');

    final res = await _client.post(
      _uri('/personal-banking/users/verify-pin'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
      body: json.encode({'oldPin': pin}),
    );

    print('📥 Verify PIN Response Status: ${res.statusCode}');
    print('📥 Verify PIN Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'PIN verified successfully';

          if (code == 0 || code == 200) {
            return {'success': true, 'message': message};
          } else {
            return {'success': false, 'message': message};
          }
        }
      } catch (e) {
        return {'success': false, 'message': 'Invalid server response: $e'};
      }
    }

    return {'success': false, 'message': 'Failed to verify PIN (Status: ${res.statusCode})'};
  }

  /// Confirm Transfer
  Future<Map<String, dynamic>> confirmTransfer(
    String accessToken,
    int toAccountId,
    int amount,
    String note,
    String pin,
  ) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'message': 'Transfer completed successfully',
        'data': {'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}', 'amount': amount, 'note': note},
      };
    }

    print('📋 Confirming transfer...');
    print('   URL: ${_uri('/personal-banking/transfer/confirm')}');
    print('   toAccountId: $toAccountId, amount: $amount');

    final res = await _client.post(
      _uri('/personal-banking/transfer/confirm'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
      body: json.encode({'toAccountId': toAccountId, 'amount': amount, 'note': note, 'pin': pin}),
    );

    print('📥 Confirm Transfer Response Status: ${res.statusCode}');
    print('📥 Confirm Transfer Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'Transfer completed successfully';

          if (code == 0 || code == 200) {
            print('✅ Transfer confirmed successfully: $message');
            return {'success': true, 'message': message, 'data': decoded['data'] ?? decoded};
          } else {
            print('❌ Transfer confirmation failed: $message');
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

    print('❌ Transfer confirmation failed with status: ${res.statusCode}');
    return {'success': false, 'message': 'Failed to confirm transfer (Status: ${res.statusCode})'};
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
