// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CyberUdayChatWidget extends StatefulWidget {
  const CyberUdayChatWidget({
    super.key,
    required this.baseUrl,
    this.client,
    this.initialOpen = false,
  });

  final String baseUrl;
  final http.Client? client;
  final bool initialOpen;

  @override
  State<CyberUdayChatWidget> createState() => _CyberUdayChatWidgetState();
}

class _CyberUdayChatWidgetState extends State<CyberUdayChatWidget> {
  late final http.Client _client;
  late final String _sessionId;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      role: _ChatRole.bot,
      text:
          'Namaste. I am Cyber Uday Digital Guardian Support AI. How can I help you stay safer online today?',
    ),
  ];

  bool _isOpen = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? http.Client();
    _sessionId =
        'cu-chat-${DateTime.now().millisecondsSinceEpoch}-${identityHashCode(this)}';
    _isOpen = widget.initialOpen;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    if (widget.client == null) {
      _client.close();
    }
    super.dispose();
  }

  Future<void> _send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(role: _ChatRole.user, text: text));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final uri = Uri.parse(widget.baseUrl).resolve('/api/v1/support/chat');
      final response = await _client
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'session_id': _sessionId, 'message': text}),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 429) {
        _appendBot(
          'I am receiving too many requests from this network. Please wait a minute and try again.',
        );
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _appendBot(
          'The support assistant is temporarily unavailable. Please try again shortly.',
        );
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      _appendBot(
        payload['reply'] as String? ??
            'I could not generate a safe answer right now.',
      );
    } on TimeoutException {
      _appendBot(
        'The support assistant took too long to respond. Please retry in a moment.',
      );
    } catch (_) {
      _appendBot(
        'I could not reach Cyber Uday support right now. Please check your connection and retry.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _appendBot(String text) {
    if (!mounted) {
      return;
    }
    setState(() {
      _messages.add(_ChatMessage(role: _ChatRole.bot, text: text));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 18,
      bottom: 18,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _isOpen
              ? _ChatWindow(key: const ValueKey('chat-window'), state: this)
              : _ChatFab(onTap: _toggleOpen),
        ),
      ),
    );
  }

  void _toggleOpen() {
    setState(() => _isOpen = !_isOpen);
    _scrollToBottom();
  }
}

class _ChatWindow extends StatelessWidget {
  const _ChatWindow({super.key, required this.state});

  final _CyberUdayChatWidgetState state;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final width = size.width < 420 ? size.width - 28 : 390.0;
    final height = size.height < 680 ? size.height - 80 : 610.0;

    return Material(
      elevation: 14,
      color: color.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: [
            _ChatHeader(onClose: state._toggleOpen),
            _QuickDoubtRow(onSend: state._send),
            Expanded(
              child: ListView.builder(
                controller: state._scrollController,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                itemCount: state._messages.length + (state._isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state._messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(message: state._messages[index]);
                },
              ),
            ),
            _ChatComposer(
              controller: state._controller,
              enabled: !state._isSending,
              onSend: () => state._send(state._controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: color.primary),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 34,
              child: _GuardianIcon(foreground: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cyber Uday Support',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Digital Guardian AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color.onPrimary.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close chat',
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, color: color.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDoubtRow extends StatelessWidget {
  const _QuickDoubtRow({required this.onSend});

  final ValueChanged<String> onSend;

  static const questions = [
    'Is my data secure?',
    'How do I report a scam?',
    'What is the Digital Bodyguard?',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        separatorBuilder: (_, separatorIndex) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(questions[index]),
            onPressed: () => onSend(questions[index]),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isUser = message.role == _ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: isUser ? color.primary : color.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser ? color.onPrimary : color.onSurface,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: _TypingIndicator(),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value + (index * 0.18)) % 1.0;
                final opacity = 0.35 + (phase < 0.5 ? phase : 1 - phase) * 1.3;
                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: opacity.clamp(0.35, 1.0)),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(top: BorderSide(color: color.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask Cyber Uday...',
                  isDense: true,
                  filled: true,
                  fillColor: color.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Send message',
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatFab extends StatelessWidget {
  const _ChatFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return FloatingActionButton(
      tooltip: 'Open Cyber Uday support',
      onPressed: onTap,
      backgroundColor: color.primary,
      foregroundColor: color.onPrimary,
      child: const SizedBox.square(
        dimension: 30,
        child: _GuardianIcon(foreground: Colors.white),
      ),
    );
  }
}

class _GuardianIcon extends StatelessWidget {
  const _GuardianIcon({required this.foreground});

  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GuardianIconPainter(foreground));
  }
}

class _GuardianIconPainter extends CustomPainter {
  const _GuardianIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.76,
        size.height * 0.56,
      ),
      Radius.circular(size.width * 0.18),
    );
    canvas.drawRRect(bubble, paint);
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.74),
      Offset(size.width * 0.26, size.height * 0.88),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.42),
      Offset(size.width * 0.55, size.height * 0.42),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.48),
      1.8,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.48),
      1.8,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _GuardianIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

enum _ChatRole { user, bot }

class _ChatMessage {
  const _ChatMessage({required this.role, required this.text});

  final _ChatRole role;
  final String text;
}
