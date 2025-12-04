import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({required this.id, required this.text, required this.isUser, required this.timestamp});

  String get formattedTime {
    return DateFormat('HH:mm').format(timestamp);
  }

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, text, isUser, timestamp];
}
