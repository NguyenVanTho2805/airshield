import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/chat_message.dart';
import '../../data/repositories/chatbot_repository.dart';

// ==================== EVENTS ====================

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object?> get props => [];
}

/// Send a message to the chatbot
class SendMessage extends ChatbotEvent {
  final String message;

  const SendMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Clear chat history
class ClearChat extends ChatbotEvent {
  const ClearChat();
}

/// Load existing session
class LoadSession extends ChatbotEvent {
  final String sessionId;

  const LoadSession({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

// ==================== STATES ====================

abstract class ChatbotState extends Equatable {
  final List<ChatMessage> messages;
  final String? sessionId;

  const ChatbotState({
    this.messages = const [],
    this.sessionId,
  });

  @override
  List<Object?> get props => [messages, sessionId];
}

/// Initial state - empty chat
class ChatbotInitial extends ChatbotState {
  const ChatbotInitial() : super();
}

/// Waiting for AI response
class ChatbotLoading extends ChatbotState {
  const ChatbotLoading({
    required super.messages,
    super.sessionId,
  });
}

/// Chat ready with messages
class ChatbotReady extends ChatbotState {
  const ChatbotReady({
    required super.messages,
    super.sessionId,
  });
}

/// Error state
class ChatbotError extends ChatbotState {
  final String error;

  const ChatbotError({
    required this.error,
    required super.messages,
    super.sessionId,
  });

  @override
  List<Object?> get props => [error, messages, sessionId];
}

// ==================== BLOC ====================

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ChatbotRepository _repository;

  ChatbotBloc({required ChatbotRepository repository})
      : _repository = repository,
        super(const ChatbotInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<LoadSession>(_onLoadSession);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatbotState> emit,
  ) async {
    // Add user message to list
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];

    // Show loading state
    emit(ChatbotLoading(
      messages: updatedMessages,
      sessionId: state.sessionId,
    ));

    try {
      // Get AI response
      final response = await _repository.sendMessage(
        message: event.message,
        sessionId: state.sessionId,
        includeAqiContext: true,
      );

      // Add AI response
      final allMessages = [...updatedMessages, response];

      emit(ChatbotReady(
        messages: allMessages,
        sessionId: state.sessionId,
      ));
    } catch (e) {
      emit(ChatbotError(
        error: e.toString(),
        messages: updatedMessages,
        sessionId: state.sessionId,
      ));
    }
  }

  void _onClearChat(
    ClearChat event,
    Emitter<ChatbotState> emit,
  ) {
    emit(const ChatbotInitial());
  }

  Future<void> _onLoadSession(
    LoadSession event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading(messages: state.messages, sessionId: event.sessionId));

    try {
      final session = await _repository.getSession(event.sessionId);
      emit(ChatbotReady(
        messages: session.messages,
        sessionId: session.id,
      ));
    } catch (e) {
      emit(ChatbotError(
        error: e.toString(),
        messages: state.messages,
        sessionId: event.sessionId,
      ));
    }
  }
}
