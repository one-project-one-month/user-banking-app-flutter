import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class QRPaymentService {
  String? baseUrl = "http://10.0.2.2:7777";
  final http.Client _client;
  WebSocketChannel? _channel;
  StreamController<QRPaymentEvent>? _eventController;

  QRPaymentService({this.baseUrl, http.Client? client}) 
    : _client = client ?? http.Client();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Generate QR to Pay (Customer shows this QR to merchant)
  /// POST /personal-banking/scan/qr-to-pay/generate
  /// Response: { "code": 0, "message": "string", "data": { "token": "string" } }
  Future<String> generateQRToPay(String accessToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'demo_qr_to_pay_token_${DateTime.now().millisecondsSinceEpoch}';
    }

    print('🔐 Generating QR to Pay...');
    print('   URL: ${_uri('/personal-banking/scan/qr-to-pay/generate')}');

    final res = await _client.post(
      _uri('/personal-banking/scan/qr-to-pay/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('📥 QR to Pay Response Status: ${res.statusCode}');
    print('📥 QR to Pay Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            throw QRPaymentException(decoded['message'] ?? 'Failed to generate QR');
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic> && data.containsKey('token')) {
              final token = data['token'] as String;
              print('✅ QR to Pay token generated: ${token.substring(0, 20)}...');
              return token;
            }
          }
        }
      } catch (e) {
        if (e is QRPaymentException) rethrow;
        print('❌ JSON parsing error: $e');
        throw QRPaymentException('Invalid response format: $e');
      }
    }

    throw QRPaymentException('Failed to generate QR to Pay (Status: ${res.statusCode})');
  }

  /// Generate QR to Receive (Merchant generates QR with amount)
  /// POST /personal-banking/scan/qr-to-receive/generate
  /// Body: { "amount": 1000, "note": "Coffee payment" }
  /// Response: { "code": 0, "message": "string", "data": { "token": "string" } }
  Future<String> generateQRToReceive(String accessToken, double amount, String note) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'demo_qr_to_receive_token_${DateTime.now().millisecondsSinceEpoch}';
    }

    print('💰 Generating QR to Receive...');
    print('   Amount: $amount, Note: $note');
    print('   URL: ${_uri('/personal-banking/scan/qr-to-receive/generate')}');

    final res = await _client.post(
      _uri('/personal-banking/scan/qr-to-receive/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'amount': amount,
        'note': note,
      }),
    );

    print('📥 QR to Receive Response Status: ${res.statusCode}');
    print('📥 QR to Receive Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          if (code != null && code != 0 && code != 200) {
            throw QRPaymentException(decoded['message'] ?? 'Failed to generate QR');
          }

          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            if (data is Map<String, dynamic> && data.containsKey('token')) {
              final token = data['token'] as String;
              print('✅ QR to Receive token generated: ${token.substring(0, 20)}...');
              return token;
            }
          }
        }
      } catch (e) {
        if (e is QRPaymentException) rethrow;
        print('❌ JSON parsing error: $e');
        throw QRPaymentException('Invalid response format: $e');
      }
    }

    throw QRPaymentException('Failed to generate QR to Receive (Status: ${res.statusCode})');
  }

  /// Scan QR to Receive (Merchant scans customer's QR)
  /// POST /personal-banking/scan/qr-to-receive/scan
  /// Body: { "token": "scanned_token" }
  /// Response: { "code": 0, "message": "string", "data": true }
  Future<Map<String, dynamic>> scanQRToReceive(String accessToken, String scannedToken) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'success': true,
        'message': 'QR scanned successfully',
        'data': {
          'customerName': 'John Doe',
          'amount': 50000,
        }
      };
    }

    print('📷 Scanning QR to Receive...');
    print('   Token: ${scannedToken.substring(0, 20)}...');

    final res = await _client.post(
      _uri('/personal-banking/scan/qr-to-receive/scan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'token': scannedToken}),
    );

    print('📥 Scan Response Status: ${res.statusCode}');
    print('📥 Scan Response Body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code'];
          final message = decoded['message'] ?? 'Scan successful';

          if (code == 0 || code == 200) {
            print('✅ QR scanned successfully: $message');
            return {
              'success': true,
              'message': message,
              'data': decoded['data'] ?? decoded
            };
          } else {
            return {'success': false, 'message': message};
          }
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        return {'success': false, 'message': 'Invalid server response: $e'};
      }
    }

    return {'success': false, 'message': 'Failed to scan QR (Status: ${res.statusCode})'};
  }

  /// Subscribe to QR Payment Events (WebSocket)
  /// GET /personal-banking/scan/qr-to-pay/subscribe?token={token}
  /// This listens for when merchant scans customer's QR code
  Stream<QRPaymentEvent> subscribeToQRPayments(String token) {
    _eventController?.close();
    _eventController = StreamController<QRPaymentEvent>.broadcast();

    if (baseUrl == null) {
      // Demo mode - simulate scan after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        _eventController?.add(QRPaymentEvent(
          type: QREventType.scanned,
          merchantName: 'Demo 7-Eleven',
          amount: 50000,
          timestamp: DateTime.now(),
        ));
      });
      return _eventController!.stream;
    }

    try {
      // Convert HTTP URL to WebSocket URL
      final wsUrl = baseUrl!.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
      final uri = Uri.parse('$wsUrl/personal-banking/scan/qr-to-pay/subscribe?token=$token');
      
      print('🔌 Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (message) {
          print('📨 WebSocket message received: $message');
          try {
            final decoded = json.decode(message);
            if (decoded is Map<String, dynamic>) {
              final event = QRPaymentEvent.fromJson(decoded);
              _eventController?.add(event);
            }
          } catch (e) {
            print('❌ Error parsing WebSocket message: $e');
            _eventController?.addError(e);
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _eventController?.addError(QRPaymentException('WebSocket error: $error'));
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _eventController?.add(QRPaymentEvent(
            type: QREventType.connectionClosed,
            timestamp: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      print('❌ Failed to connect to WebSocket: $e');
      _eventController?.addError(QRPaymentException('Failed to connect: $e'));
    }

    return _eventController!.stream;
  }

  /// Close WebSocket connection
  void closeSubscription() {
    print('🔌 Closing WebSocket subscription...');
    _channel?.sink.close();
    _eventController?.close();
    _channel = null;
    _eventController = null;
  }

  void dispose() {
    closeSubscription();
    _client.close();
  }
}

/// QR Payment Event Types
enum QREventType {
  scanned,           // QR code was scanned
  paymentRequested,  // Merchant requested payment
  paymentCompleted,  // Payment was completed
  paymentFailed,     // Payment failed
  connectionClosed,  // WebSocket connection closed
}

/// QR Payment Event
class QRPaymentEvent {
  final QREventType type;
  final String? merchantName;
  final double? amount;
  final String? note;
  final String? transactionId;
  final DateTime timestamp;

  QRPaymentEvent({
    required this.type,
    this.merchantName,
    this.amount,
    this.note,
    this.transactionId,
    required this.timestamp,
  });

  factory QRPaymentEvent.fromJson(Map<String, dynamic> json) {
    QREventType type;
    switch (json['type']?.toString().toLowerCase()) {
      case 'scanned':
        type = QREventType.scanned;
        break;
      case 'payment_requested':
        type = QREventType.paymentRequested;
        break;
      case 'payment_completed':
        type = QREventType.paymentCompleted;
        break;
      case 'payment_failed':
        type = QREventType.paymentFailed;
        break;
      default:
        type = QREventType.scanned;
    }

    return QRPaymentEvent(
      type: type,
      merchantName: json['merchantName'] ?? json['merchant_name'],
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : null,
      note: json['note'],
      transactionId: json['transactionId'] ?? json['transaction_id'],
      timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'merchantName': merchantName,
      'amount': amount,
      'note': note,
      'transactionId': transactionId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class QRPaymentException implements Exception {
  final String message;
  QRPaymentException(this.message);

  @override
  String toString() => 'QRPaymentException: $message';
}