import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/error_handler.dart';

/// Chat input field with send button and voice input
class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({
    super.key,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  
  // Speech to Text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
          }
        },
      );
    } catch (e, stack) {
      ErrorHandler().logError(e, stack, reason: 'speech_init_failed');
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      // Check permission
      final status = await Permission.microphone.request();
      if (status.isGranted && _speechEnabled) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              // Optional: move cursor to end
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          },
          localeId: 'vi_VN', // Default to Vietnamese, or omit for system default
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: _isListening ? 'Đang nghe...' : 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                    color: _isListening ? Colors.redAccent : colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: _isListening
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: _WaveAnimation(isAnimating: true),
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _isListening ? 0 : 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Microphone Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: _toggleListening,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.redAccent : colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: _isListening
                    ? Colors.redAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          // Send Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: _hasText ? _sendMessage : null,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.send_rounded,
                  key: ValueKey(_hasText),
                  color: _hasText
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              style: IconButton.styleFrom(
                backgroundColor: _hasText
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveAnimation extends StatefulWidget {
  final bool isAnimating;
  const _WaveAnimation({required this.isAnimating});

  @override
  State<_WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<_WaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (i * 100)),
      ),
    );

    _animations = _controllers.map((c) => Tween<double>(begin: 0.2, end: 1.0).animate(c)).toList();

    if (widget.isAnimating) {
      _startAnimating();
    }
  }

  void _startAnimating() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isAnimating) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(_WaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimating();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      for (var c in _controllers) {
        c.stop();
        c.value = 0.2;
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: 20 * _animations[index].value,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}

