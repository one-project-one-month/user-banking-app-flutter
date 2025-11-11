import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;

  TransactionService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Get recent transfers (for home screen - shows 5 most recent)
  /// GET /personal-banking/users/recent-transfer-list
  /// Headers: Authorization: Bearer {token}
  /// Response: {
  ///   "code": 200,
  ///   "message": "Recent transfers retrieved",
  ///   "data": {
  ///     "recentTransferListOptions": [...]
  ///   }
  /// }
  Future<List<RecentTransfer>> getRecentTransfers(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockRecentTransfers();
    }

    print('📋 Fetching recent transfers...');
    print('   URL: ${_uri('/personal-banking/users/recent-transfer-list')}');

    final res = await _client.get(
      _uri('/personal-banking/users/recent-transfer-list'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    );

    print('📥 Recent Transfers Response Status: ${res.statusCode}');
    print('📥 Recent Transfers Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to fetch recent transfers';
            throw TransactionServiceException(message);
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              // Try both possible field names
              final transfersList = data['recentTransferListOptions'] ?? data['transferListOptions'];
              if (transfersList is List) {
                print('✅ Found ${transfersList.length} recent transfers');
                return transfersList
                    .map((item) => RecentTransfer.fromJson(Map<String, dynamic>.from(item)))
                    .take(5) // Limit to 5 most recent
                    .toList();
              }
            }
          }
        }

        print('⚠️ Unexpected response format, returning empty list');
        return [];
      } catch (e) {
        if (e is TransactionServiceException) rethrow;
        print('❌ JSON parsing error: $e');
        throw TransactionServiceException('Invalid response format: $e');
      }
    }

    // Handle error responses
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw TransactionServiceException('Failed to fetch recent transfers: $serverMsg');
        }
      }
    } catch (e) {
      if (e is TransactionServiceException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw TransactionServiceException('Failed to fetch recent transfers: $fallback');
  }

  /// Get transaction history (for transactions history screen - shows all)
  /// GET /personal-banking/users/transaction-history
  /// Headers: Authorization: Bearer {token}
  /// Response: {
  ///   "code": 200,
  ///   "message": "Transaction history retrieved",
  ///   "data": {
  ///     "recentTransferListOptions": [...] // API uses same field name!
  ///   }
  /// }
  Future<List<RecentTransfer>> getTransactionHistory(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockTransactionHistory();
    }

    print('📋 Fetching transaction history...');
    print('   URL: ${_uri('/personal-banking/users/transaction-history')}');

    final res = await _client.get(
      _uri('/personal-banking/users/transaction-history'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    );

    print('📥 Transaction History Response Status: ${res.statusCode}');
    print('📥 Transaction History Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to fetch transaction history';
            throw TransactionServiceException(message);
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              // API uses 'recentTransferListOptions' for both endpoints!
              // Try both possible field names to be safe
              final transfersList = data['recentTransferListOptions'] ?? data['transferListOptions'];
              if (transfersList is List) {
                print('✅ Found ${transfersList.length} transactions in history');
                return transfersList.map((item) => RecentTransfer.fromJson(Map<String, dynamic>.from(item))).toList();
              } else {
                print('⚠️ transfersList is not a List: ${transfersList.runtimeType}');
              }
            } else {
              print('⚠️ data is not a Map: ${data.runtimeType}');
            }
          } else {
            print('⚠️ Response does not contain "data" field');
          }
        }

        print('⚠️ Unexpected response format, returning empty list');
        print('   Decoded type: ${decoded.runtimeType}');
        return [];
      } catch (e) {
        if (e is TransactionServiceException) rethrow;
        print('❌ JSON parsing error: $e');
        throw TransactionServiceException('Invalid response format: $e');
      }
    }

    // Handle error responses
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw TransactionServiceException('Failed to fetch transaction history: $serverMsg');
        }
      }
    } catch (e) {
      if (e is TransactionServiceException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw TransactionServiceException('Failed to fetch transaction history: $fallback');
  }

  // Mock data for testing
  List<RecentTransfer> _getMockRecentTransfers() {
    return List.generate(5, (index) {
      return RecentTransfer(
        user: TransferUser(id: index + 1, name: 'User ${index + 1}'),
        account: TransferAccount(id: index + 1, accountNumber: '100000000${index + 1}', balance: (index + 1) * 10000.0),
        time: '${10 + index}:00 AM',
        isIncome: index % 2 == 0,
        quickPay: index % 3 == 0,
      );
    });
  }

  List<RecentTransfer> _getMockTransactionHistory() {
    return List.generate(20, (index) {
      return RecentTransfer(
        user: TransferUser(id: index + 1, name: 'User ${index + 1}'),
        account: TransferAccount(id: index + 1, accountNumber: '100000000${index + 1}', balance: (index + 1) * 5000.0),
        time: '${10 + (index % 12)}:${(index * 5) % 60} ${index % 2 == 0 ? 'AM' : 'PM'}',
        isIncome: index % 2 == 0,
        quickPay: index % 4 == 0,
      );
    });
  }

  void dispose() {
    _client.close();
  }
}

class TransactionServiceException implements Exception {
  final String message;
  TransactionServiceException(this.message);

  @override
  String toString() => 'TransactionServiceException: $message';
}
