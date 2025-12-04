import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/cache_service.dart';

class AIAssistantApiService {
  String? baseUrl = "https://136.112.160.13:7777";
  final http.Client _client;
  final CacheService cache;
 
  AIAssistantApiService({this.baseUrl, http.Client? client, CacheService? cacheService})
    : _client = client ?? http.Client(),
      cache = cacheService ?? CacheService();

  Uri _uri(String path) {
    if (baseUrl == null) throw StateError('No baseUrl configured');
    return Uri.parse(baseUrl! + path);
  }

  /// Ask a question to the AI assistant
  /// POST /api/faqs/ask
  /// Body: { "question": "string" }
  /// Response: {
  ///   "code": 0,
  ///   "message": "string",
  ///   "data": {
  ///     "answer": "string"
  ///   }
  /// }
  Future<String> askQuestion(String question) async {
    if (baseUrl == null) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockResponse(question);
    }

    print('🤖 Asking AI: $question');
    print('   URL: ${_uri('/api/faqs/ask')}');

    try {
      final token = await cache.getToken();

      final res = await _client.post(
        _uri('/api/faqs/ask'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.accessToken.isNotEmpty) 'Authorization': 'Bearer ${token.accessToken}',
        },
        body: json.encode({'question': question}),
      );

      print('📥 AI Response Status: ${res.statusCode}');
      print('📥 AI Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = json.decode(res.body);

          if (decoded is Map<String, dynamic>) {
            final code = decoded['code'];

            // Check for success codes
            if (code == 0 || code == 200) {
              // Try to get answer from data field
              if (decoded.containsKey('data')) {
                final data = decoded['data'];

                if (data is Map<String, dynamic>) {
                  final answer = data['answer']?.toString();
                  if (answer != null && answer.isNotEmpty) {
                    print('✅ Got AI response: ${answer.substring(0, answer.length > 50 ? 50 : answer.length)}...');
                    return answer;
                  }
                } else if (data is String) {
                  print('✅ Got AI response: ${data.substring(0, data.length > 50 ? 50 : data.length)}...');
                  return data;
                }
              }

              // If no data field, check if answer is at root level
              if (decoded.containsKey('answer')) {
                final answer = decoded['answer']?.toString();
                if (answer != null && answer.isNotEmpty) {
                  print('✅ Got AI response: ${answer.substring(0, answer.length > 50 ? 50 : answer.length)}...');
                  return answer;
                }
              }

              // If message contains the answer
              if (decoded.containsKey('message')) {
                final message = decoded['message']?.toString();
                if (message != null && message.isNotEmpty && message != 'Success') {
                  print(
                    '✅ Got AI response from message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...',
                  );
                  return message;
                }
              }

              print('❌ Answer not found in response');
              throw AIAssistantApiException('Answer not found in response');
            } else {
              final message = decoded['message'] ?? 'Failed to get AI response';
              print('❌ Error code: $code, message: $message');
              throw AIAssistantApiException(message);
            }
          }
        } catch (e) {
          if (e is AIAssistantApiException) rethrow;
          print('❌ JSON parsing error: $e');
          throw AIAssistantApiException('Invalid response format: $e');
        }
      }

      // Handle error responses
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final serverMsg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
          if (serverMsg != null) {
            throw AIAssistantApiException('AI request failed: $serverMsg');
          }
        }
      } catch (e) {
        if (e is AIAssistantApiException) rethrow;
      }

      final fallback = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
      throw AIAssistantApiException('Failed to get AI response: $fallback');
    } catch (e) {
      if (e is AIAssistantApiException) rethrow;
      print('❌ Network error: $e');
      throw AIAssistantApiException('Network error: $e');
    }
  }

  // Mock responses for testing
  String _getMockResponse(String question) {
    final lowerQ = question.toLowerCase();

    if (lowerQ.contains('balance')) {
      return 'You can check your balance on the home screen. Your current balance is displayed at the top of the screen. You can also tap the eye icon to show or hide your balance.';
    } else if (lowerQ.contains('transaction')) {
      return 'To view your recent transactions, you can check the home screen for recent history or tap "See All" to view your complete transaction history. You can also filter transactions by date or type.';
    } else if (lowerQ.contains('transfer')) {
      return 'To transfer money:\n1. Go to the Transfer screen\n2. Select or enter the recipient account\n3. Enter the amount and note\n4. Confirm the details\n5. Enter your PIN to complete the transfer';
    } else if (lowerQ.contains('pin')) {
      return 'To set or change your PIN, go to Settings and tap on "Set Transaction PIN". You will need to enter your current PIN to set a new one.';
    } else if (lowerQ.contains('qr')) {
      return 'You can use QR codes to make payments:\n• QR to Pay: Generate a QR for others to scan\n• QR to Receive: Generate a QR to receive payments\n• Scan to Pay: Scan merchant QR codes\n• Scan to Receive: Scan to receive payment details';
    } else if (lowerQ.contains('favorite') || lowerQ.contains('nickname')) {
      return 'You can save frequently used accounts as favorites:\n1. Go to Settings > Nickname\n2. Add a new favorite with the account ID and a friendly nickname\n3. Use these favorites for quick transfers';
    } else {
      return 'I can help you with:\n• Checking your balance\n• Viewing transactions\n• Making transfers\n• Setting up PIN\n• Using QR payments\n• Managing favorites\n\nWhat would you like to know more about?';
    }
  }

  void dispose() {
    _client.close();
  }
}

class AIAssistantApiException implements Exception {
  final String message;
  AIAssistantApiException(this.message);

  @override
  String toString() => 'AIAssistantApiException: $message';
}
