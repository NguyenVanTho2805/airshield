import '../../../../core/network/api_client.dart';
import '../models/chat_message.dart';

/// Repository for chatbot API interactions
class ChatbotRepository {
  final ApiClient _apiClient;

  ChatbotRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Send a chat message and get AI response
  Future<ChatMessage> sendMessage({
    required String message,
    String? sessionId,
    double? latitude,
    double? longitude,
    bool includeAqiContext = true,
  }) async {
    try {
      final response = await _apiClient.post(
        '/chatbot/chat',
        data: {
          'message': message,
          'session_id': sessionId,
          'latitude': latitude,
          'longitude': longitude,
          'include_aqi_context': includeAqiContext,
        },
      );

      return ChatMessage.fromJson(response.data);
    } catch (e) {
      // Return mock response for demo/offline mode
      return _getMockResponse(message);
    }
  }

  /// Get chat session history
  Future<ChatSession> getSession(String sessionId) async {
    try {
      final response = await _apiClient.get('/chatbot/sessions/$sessionId');
      return ChatSession.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load session: $e');
    }
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    await _apiClient.delete('/chatbot/sessions/$sessionId');
  }

  /// Mock response for offline/demo mode
  ChatMessage _getMockResponse(String message) {
    final lowerMessage = message.toLowerCase();
    String response;

    if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
      response = 'Xin chào! Tôi là AirShield Assistant. Tôi có thể giúp bạn:\n'
          '• Kiểm tra chất lượng không khí\n'
          '• Tư vấn sức khỏe theo AQI\n'
          '• Điều khiển thiết bị lọc không khí\n\n'
          'Bạn cần giúp gì?';
    } else if (lowerMessage.contains('aqi') || lowerMessage.contains('chất lượng')) {
      response = 'Chất lượng không khí hiện tại:\n'
          '🟢 **AQI: 45** - Tốt\n'
          '• PM2.5: 12 µg/m³\n'
          '• PM10: 28 µg/m³\n\n'
          'Bạn có thể yên tâm hoạt động ngoài trời!';
    } else if (lowerMessage.contains('bật') || lowerMessage.contains('máy lọc')) {
      response = 'Tôi sẽ giúp bạn điều khiển máy lọc không khí. '
          'Vui lòng vào mục **Smart Home** để chọn thiết bị cần điều khiển.';
    } else {
      response = 'Tôi là AirShield Assistant. Tôi có thể giúp bạn về:\n'
          '• Chất lượng không khí\n'
          '• Tư vấn sức khỏe\n'
          '• Điều khiển thiết bị\n\n'
          'Hãy hỏi tôi về AQI hoặc các vấn đề sức khỏe liên quan!';
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }
}
