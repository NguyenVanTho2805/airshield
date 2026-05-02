import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../bloc/chatbot_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../../data/models/chat_message.dart';

/// Main chatbot page with chat interface
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool isVoiceEnabled = true;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _speak(String text) async {
    if (isVoiceEnabled) {
      await flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('AirShield Assistant'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            flutterTts.stop();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isVoiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                isVoiceEnabled = !isVoiceEnabled;
                if (!isVoiceEnabled) {
                  flutterTts.stop();
                }
              });
            },
            tooltip: 'Âm thanh Bot',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<ChatbotBloc>().add(const ClearChat());
            },
            tooltip: 'Xóa lịch sử',
          ),
        ],
      ),
      body: BlocListener<ChatbotBloc, ChatbotState>(
        listener: (context, state) {
          if (state is ChatbotReady && state.messages.isNotEmpty) {
            final lastMessage = state.messages.last;
            if (lastMessage.role == MessageRole.assistant) {
              _speak(lastMessage.content);
            }
          }
        },
        child: Column(
          children: [
            // Chat messages list
            Expanded(
              child: BlocBuilder<ChatbotBloc, ChatbotState>(
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.messages.length + (state is ChatbotLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show typing indicator at top (since reversed)
                      if (state is ChatbotLoading && index == 0) {
                        return const _TypingIndicator();
                      }

                      final messageIndex = state is ChatbotLoading ? index - 1 : index;
                      final reversedIndex = state.messages.length - 1 - messageIndex;
                      final message = state.messages[reversedIndex];

                      return ChatBubble(message: message);
                    },
                  );
                },
              ),
            ),

            // Input field
            ChatInput(
              onSend: (message) {
                flutterTts.stop();
                context.read<ChatbotBloc>().add(SendMessage(message: message));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final suggestions = [
      '👋 Xin chào!',
      '🌍 Chất lượng không khí thế nào?',
      '💨 PM2.5 là gì?',
      '🏠 Bật máy lọc không khí',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AirShield Assistant',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hỏi tôi về chất lượng không khí, sức khỏe,\nhoặc điều khiển thiết bị smart home',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    context.read<ChatbotBloc>().add(
                          SendMessage(message: suggestion),
                        );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Typing indicator animation
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(context, 0),
            const SizedBox(width: 4),
            _buildDot(context, 1),
            const SizedBox(width: 4),
            _buildDot(context, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(
                  (128 + (127 * (1 - value).abs())).toInt(),
                ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
