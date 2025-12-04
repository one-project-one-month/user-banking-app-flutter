import 'package:equatable/equatable.dart';
import '../models/chat_message_model.dart';

enum AIAssistantStatus { initial, loading, success, error }

class AIAssistantState extends Equatable {
  final AIAssistantStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;

  const AIAssistantState({
    this.status = AIAssistantStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  AIAssistantState copyWith({
    AIAssistantStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
  }) {
    return AIAssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == AIAssistantStatus.loading;
  bool get hasError => status == AIAssistantStatus.error;

  @override
  List<Object?> get props => [status, messages, errorMessage];
}