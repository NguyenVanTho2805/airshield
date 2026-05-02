/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final ChatAction? action;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.action,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['message'] ?? json['content'] ?? '',
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      action: json['action'] != null
          ? ChatAction.fromJson(json['action'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
      };
}

enum MessageRole { user, assistant, system }

/// Action triggered by chatbot
class ChatAction {
  final String actionType;
  final Map<String, dynamic>? payload;

  const ChatAction({
    required this.actionType,
    this.payload,
  });

  factory ChatAction.fromJson(Map<String, dynamic> json) {
    return ChatAction(
      actionType: json['action_type'] ?? 'none',
      payload: json['payload'],
    );
  }
}

/// Chat session
class ChatSession {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  const ChatSession({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      title: json['title'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          [],
    );
  }
}
