import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/qr_models.dart';

class QRApiService {
  String? baseUrl = "https://136.112.160.13:7777";
  final http.Client _client;

  QRApiService({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Generate QR to Receive
  /// POST /personal-banking/scan/qr-to-receive/generate
  /// Body: { "amount": 0, "note": "string" }
  /// Response: { "code": 0, "message": "string", "data": { "token": "string" } }
  Future<QRToReceive> generateQRToReceive(String accessToken, double amount, String note) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return QRToReceive(
        token: 'mock_receive_token_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        note: note,
      );
    }

    print('🔋 Generating QR to Receive...');
    print('   URL: ${_uri('/personal-banking/scan/qr-to-receive/generate')}');
    print('   Amount: $amount, Note: $note');
    print('   Token: ${accessToken.substring(0, 20)}...');

    final res = await _client.post(
      _uri('/personal-banking/scan/qr-to-receive/generate'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
      body: json.encode({'amount': amount, 'note': note}),
    );

    print('🔥 Generate QR Response Status: ${res.statusCode}');
    print('🔥 Generate QR Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'QR generated successfully';

          // Check for success codes
          if (code == 0 || code == 200) {
            // Try to get token from data field
            if (decoded.containsKey('data')) {
              final data = decoded['data'];

              if (data is Map<String, dynamic>) {
                final token = data['token']?.toString() ?? '';

                if (token.isNotEmpty) {
                  print('✅ QR to Receive generated: $token');
                  return QRToReceive(token: token, amount: amount, note: note);
                }
              } else if (data is String) {
                // If data is directly a string (token)
                print('✅ QR to Receive generated: $data');
                return QRToReceive(token: data, amount: amount, note: note);
              }
            }

            // If no data field, check if token is at root level
            if (decoded.containsKey('token')) {
              final token = decoded['token']?.toString() ?? '';
              if (token.isNotEmpty) {
                print('✅ QR to Receive generated: $token');
                return QRToReceive(token: token, amount: amount, note: note);
              }
            }

            print('❌ Token not found in response');
            throw QRApiException('Token not found in response: $decoded');
          } else {
            print('❌ Error code: $code, message: $message');
            throw QRApiException(message);
          }
        }
      } catch (e) {
        if (e is QRApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw QRApiException('Invalid response format: $e');
      }
    }

    // Handle error responses
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw QRApiException('Failed to generate QR: $serverMsg');
        }
      }
    } catch (e) {
      if (e is QRApiException) rethrow;
    }

    final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw QRApiException('Failed to generate QR to Receive: $fallback');
  }

  /// Fetch account holder name by account number
  /// Uses the transfer prepare API to get account details including name
  Future<String> getAccountName(String accessToken, String accountNumber) async {
    if (baseUrl == null) {
      return 'User';
    }

    try {
      final candidatePaths = [
        '/personal-banking/transfer/to-account-number/prepare',
        '/personal-banking/transfer/account-number/prepare',
      ];

      for (final path in candidatePaths) {
        try {
          final res = await _client.post(
            _uri(path),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
            body: json.encode({'toAccountNumber': accountNumber}),
          );

          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = json.decode(res.body);
            if (decoded is Map<String, dynamic>) {
              final code = decoded['code'];
              if (code == 0 || code == 200) {
                final data = decoded['data'] ?? decoded['result'];
                if (data is Map<String, dynamic>) {
                  final user = data['userDetails'] ?? data['user_details'] ?? data['recipientDetails'];
                  if (user is Map<String, dynamic>) {
                    final name = user['fullName'] ?? user['fullname'] ?? user['name'] ?? user['username'] ?? '';
                    if (name.isNotEmpty) {
                      return name.toString();
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          continue; // Try next path
        }
      }
    } catch (e) {
      print('⚠️ Error fetching account name: $e');
    }

    return 'User'; // Default fallback
  }

  /// Scan QR to Receive (Process scanned token)
  /// POST /personal-banking/scan/qr-to-receive/scan
  /// Body: { "token": "string" }
  Future<ScannedQRData> scanQRToReceive(String accessToken, String token) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ScannedQRData(
        fromAccountId: '3',
        fromAccountNumber: '1000000002',
        fromBalance: 75000,
        fromName: 'Jane Smith',
        toAccountId: '2',
        toAccountNumber: '1000000001',
        toBalance: 50000,
        toName: 'John Doe',
        amount: 10000,
        note: 'Test payment',
      );
    }

    print('🔋 Scanning QR to Receive...');
    print('   Token: ${token.length > 10 ? token.substring(0, 10) : token}...');

    final res = await _client.post(
      _uri('/personal-banking/scan/qr-to-receive/scan'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
      body: json.encode({'token': token}),
    );

    print('🔥 Scan QR Response Status: ${res.statusCode}');
    print('🔥 Scan QR Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];

          if (code == 0 || code == 200) {
            final data = decoded['data'] ?? decoded;
            print('✅ QR scanned successfully');
            
            // Parse the scanned data
            final scannedData = ScannedQRData.fromJson(data);
            
            // Fetch names for both accounts
            final fromName = await getAccountName(accessToken, scannedData.fromAccountNumber);
            final toName = await getAccountName(accessToken, scannedData.toAccountNumber);
            
            // Return data with names
            return scannedData.copyWith(fromName: fromName, toName: toName);
          } else {
            final message = decoded['message'] ?? 'Failed to scan QR';
            throw QRApiException(message);
          }
        }
      } catch (e) {
        if (e is QRApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw QRApiException('Invalid response format: $e');
      }
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw QRApiException('Failed to scan QR: $serverMsg');
        }
      }
    } catch (e) {
      if (e is QRApiException) rethrow;
    }

    throw QRApiException('Failed to scan QR (${res.statusCode})');
  }

  /// Generate QR to Pay
  /// POST /personal-banking/scan/qr-to-pay/generate
  Future<QRToPay> generateQRToPay(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return QRToPay(token: 'mock_pay_token_${DateTime.now().millisecondsSinceEpoch}');
    }

    print('🔋 Generating QR to Pay...');

    final res = await _client.post(
      _uri('/personal-banking/scan/qr-to-pay/generate'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
    );

    print('🔥 Generate QR to Pay Response Status: ${res.statusCode}');
    print('🔥 Generate QR to Pay Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];

          if (code == 0 || code == 200) {
            // Try to get token from data field
            if (decoded.containsKey('data')) {
              final data = decoded['data'];

              if (data is Map<String, dynamic>) {
                final token = data['token']?.toString() ?? '';
                if (token.isNotEmpty) {
                  print('✅ QR to Pay generated: $token');
                  return QRToPay(token: token);
                }
              } else if (data is String) {
                print('✅ QR to Pay generated: $data');
                return QRToPay(token: data);
              }
            }

            // Check root level
            if (decoded.containsKey('token')) {
              final token = decoded['token']?.toString() ?? '';
              if (token.isNotEmpty) {
                print('✅ QR to Pay generated: $token');
                return QRToPay(token: token);
              }
            }

            throw QRApiException('Token not found in response');
          } else {
            final message = decoded['message'] ?? 'Failed to generate QR to Pay';
            throw QRApiException(message);
          }
        }
      } catch (e) {
        if (e is QRApiException) rethrow;
        print('❌ JSON parsing error: $e');
        throw QRApiException('Invalid response format: $e');
      }
    }

    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (serverMsg != null) {
          throw QRApiException('Failed to generate QR to Pay: $serverMsg');
        }
      }
    } catch (e) {
      if (e is QRApiException) rethrow;
    }

    throw QRApiException('Failed to generate QR to Pay (${res.statusCode})');
  }

  /// Subscribe to QR to Pay events (SSE)
  /// GET /personal-banking/scan/qr-to-pay/subscribe?token=string
  Stream<Map<String, dynamic>> subscribeToQRToPay(String accessToken, String token) async* {
    if (baseUrl == null) {
      await Future.delayed(const Duration(seconds: 60));
      yield {'timeout': 0};
      return;
    }

    print('🔋 Subscribing to QR to Pay events...');
    print('   Token: ${token.length > 10 ? token.substring(0, 10) : token}...');

    final uri = _uri('/personal-banking/scan/qr-to-pay/subscribe?token=$token');

    final request = http.Request('GET', uri);
    request.headers.addAll({'Accept': 'text/event-stream', 'Authorization': 'Bearer $accessToken'});

    try {
      final response = await _client.send(request);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Connected to QR to Pay subscription');

        await for (final chunk in response.stream.transform(utf8.decoder)) {
          print('🔥 SSE Event received: $chunk');

          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data:')) {
              final jsonStr = line.substring(5).trim();
              try {
                final data = json.decode(jsonStr);
                yield data;
              } catch (e) {
                print('❌ Failed to parse SSE data: $e');
              }
            }
          }
        }
      } else {
        throw QRApiException('Failed to subscribe (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Subscription error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

class QRApiException implements Exception {
  final String message;
  QRApiException(this.message);

  @override
  String toString() => 'QRApiException: $message';
}
