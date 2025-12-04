import 'package:equatable/equatable.dart';

abstract class AIAssistantEvent extends Equatable {
  const AIAssistantEvent();

  @override
  List<Object?> get props => [];
}

class AIAssistantSendMessage extends AIAssistantEvent {
  final String message;

  const AIAssistantSendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class AIAssistantClearChat extends AIAssistantEvent {
  const AIAssistantClearChat();
}