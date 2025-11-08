import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;

  TransactionService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) {
      throw StateError('No baseUrl configured for TransactionService');
    }
    return Uri.parse(baseUrl! + path);
  }

  /// Get recent transfer list
  /// GET /personal-banking/users/recent-transfer-list
  /// Headers: Authorization: Bearer {token}
  /// Response: {
  ///   "code": 0,
  ///   "message": "string",
  ///   "data": {
  ///     "recentTransferListOptions": [
  ///       {
  ///         "user": { "id": 0, "name": "string" },
  ///         "account": { "id": 0, "accountNumber": "string", "balance": 0 }
  ///       }
  ///     ]
  ///   }
  /// }
  Future<List<RecentTransfer>> getRecentTransfers(String accessToken) async {
    if (baseUrl == null) {
      // Return mock data for demo mode
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        RecentTransfer(
          user: TransferUser(id: 1, name: 'John Doe'),
          account: TransferAccount(id: 1, accountNumber: '1234 5678 9012', balance: 500000),
          time: '10:30 AM',
          isIncome: true,
        ),
        RecentTransfer(
          user: TransferUser(id: 2, name: 'Jane Smith'),
          account: TransferAccount(id: 2, accountNumber: '9876 5432 1098', balance: 250000),
          time: '2:15 PM',
          isIncome: false,
        ),
        RecentTransfer(
          user: TransferUser(id: 3, name: 'Alice Johnson'),
          account: TransferAccount(id: 3, accountNumber: '4567 8901 2345', balance: 750000),
          time: '11:00 AM',
          isIncome: true,
        ),
      ];
    }

    print('📋 Fetching recent transfers...');
    print('   URL: ${_uri('/personal-banking/users/recent-transfer-list')}');
    print('   Token: ${accessToken.substring(0, 20)}...');

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
          // Check for code field (0 or 200 = success)
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            final message = decoded['message'] ?? 'Failed to fetch transfers';
            throw TransactionServiceException(message);
          }

          // Extract data
          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic> && data.containsKey('recentTransferListOptions')) {
              final transferList = data['recentTransferListOptions'];
              if (transferList is List) {
                print('✅ Found ${transferList.length} recent transfers');
                return transferList.map((item) => RecentTransfer.fromJson(item)).toList();
              }
            }
          }

          // If direct list response
          if (decoded.containsKey('recentTransferListOptions')) {
            final transferList = decoded['recentTransferListOptions'];
            if (transferList is List) {
              return transferList.map((item) => RecentTransfer.fromJson(item)).toList();
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
          throw TransactionServiceException('Failed to fetch transfers: $serverMsg');
        }
      }
    } catch (e) {
      if (e is TransactionServiceException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw TransactionServiceException('Failed to fetch recent transfers: $fallback');
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
