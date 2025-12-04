import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';
import '../services/ai_assistant_api_service.dart';
import '../models/chat_message_model.dart';

class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  final AIAssistantApiService api;

  AIAssistantBloc({AIAssistantApiService? apiService})
      : api = apiService ?? AIAssistantApiService(),
        super(const AIAssistantState()) {
    on<AIAssistantSendMessage>(_onSendMessage);
    on<AIAssistantClearChat>(_onClearChat);
  }

  Future<void> _onSendMessage(
    AIAssistantSendMessage event,
    Emitter<AIAssistantState> emit,
  ) async {
    // Add user message
    final userMessage = ChatMessage.user(event.message);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);

    emit(state.copyWith(
      status: AIAssistantStatus.loading,
      messages: updatedMessages,
    ));

    try {
      // Call FAQ API
      final response = await api.askQuestion(event.message);

      // Add AI response
      final aiMessage = ChatMessage.assistant(response);
      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(aiMessage);

      emit(state.copyWith(
        status: AIAssistantStatus.success,
        messages: finalMessages,
        errorMessage: null,
      ));
    } catch (e) {
      String errorMsg = 'Failed to get response from AI';
      if (e is AIAssistantApiException) {
        errorMsg = e.message;
      }

      print('❌ AIAssistantBloc error: $errorMsg');

      // Add error message as AI response
      final errorMessage = ChatMessage.assistant(
        "I'm sorry, I couldn't process your request at the moment. Please try again later.",
      );
      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(errorMessage);

      emit(state.copyWith(
        status: AIAssistantStatus.error,
        messages: finalMessages,
        errorMessage: errorMsg,
      ));
    }
  }

  Future<void> _onClearChat(
    AIAssistantClearChat event,
    Emitter<AIAssistantState> emit,
  ) async {
    emit(const AIAssistantState());
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}