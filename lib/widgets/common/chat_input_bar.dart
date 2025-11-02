import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Chat Input Bar
/// 
/// Message composition bar for chat interfaces
/// 
/// Example:
/// ```dart
/// ChatInputBar(
///   onSendMessage: (message) {
///     print('Sending: $message');
///   },
///   hintText: 'Type a message...',
/// )
/// ```
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onVoiceTap;
  final String hintText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool showAttachmentButton;
  final bool showVoiceButton;
  final ValueChanged<String>? onTextChanged;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.onAttachmentTap,
    this.onVoiceTap,
    this.hintText = 'Type a message...',
    this.maxLines = 5,
    this.maxLength,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.showAttachmentButton = true,
    this.showVoiceButton = false,
    this.onTextChanged,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onTextChanged?.call(_controller.text);
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).toInt()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSizes.paddingM,
        right: AppSizes.paddingM,
        top: AppSizes.paddingM,
        bottom: AppSizes.paddingM + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            if (widget.showAttachmentButton && !_hasText) ...[
              IconButton(
                onPressed: widget.enabled ? widget.onAttachmentTap : null,
                icon: const Icon(Icons.attach_file),
                color: AppColors.primary,
                tooltip: 'Attach file',
              ),
            ],

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  minLines: 1,
                  maxLength: widget.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingM,
                    ),
                    counterText: '', // Hide character counter
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: AppSizes.spacingS),

            // Send / Voice button
            AnimatedSwitcher(
              duration: AppDurations.fast,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: _hasText
                  ? // Send button
                  Container(
                      key: const ValueKey('send'),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: widget.enabled ? _sendMessage : null,
                        icon: const Icon(Icons.send),
                        color: Colors.white,
                        tooltip: 'Send message',
                      ),
                    )
                  : // Voice button (optional)
                  widget.showVoiceButton
                      ? IconButton(
                          key: const ValueKey('voice'),
                          onPressed: widget.enabled ? widget.onVoiceTap : null,
                          icon: const Icon(Icons.mic),
                          color: AppColors.primary,
                          tooltip: 'Voice message',
                        )
                      : const SizedBox(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple Chat Input
/// 
/// A minimal chat input without extra buttons
class SimpleChatInput extends StatelessWidget {
  final ValueChanged<String> onSendMessage;
  final String hintText;
  final TextEditingController? controller;

  const SimpleChatInput({
    super.key,
    required this.onSendMessage,
    this.hintText = 'Type a message...',
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ChatInputBar(
      onSendMessage: onSendMessage,
      hintText: hintText,
      controller: controller,
      showAttachmentButton: false,
      showVoiceButton: false,
    );
  }
}
