import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';

/// Chat Bubble
/// 
/// A message bubble for chat interfaces
/// 
/// Example:
/// ```dart
/// ChatBubble(
///   message: 'Hello! How can I help you?',
///   isSentByMe: true,
///   timestamp: DateTime.now(),
/// )
/// ```
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final DateTime timestamp;
  final MessageStatus? status;
  final String? senderName;
  final String? senderAvatarUrl;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.timestamp,
    this.status,
    this.senderName,
    this.senderAvatarUrl,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (for received messages)
          if (!isSentByMe && showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: AppSizes.spacingS),
          ],

          // Message bubble
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name (for received messages)
                  if (!isSentByMe && senderName != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.paddingM,
                        bottom: 4,
                      ),
                      child: Text(
                        senderName!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],

                  // Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: isSentByMe
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppSizes.radiusL),
                        topRight: const Radius.circular(AppSizes.radiusL),
                        bottomLeft: Radius.circular(
                          isSentByMe ? AppSizes.radiusL : AppSizes.radiusS,
                        ),
                        bottomRight: Radius.circular(
                          isSentByMe ? AppSizes.radiusS : AppSizes.radiusL,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.05).toInt()),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message text
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 15,
                            color: isSentByMe
                                ? Colors.white
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),

                        // Timestamp and status
                        if (showTimestamp || (isSentByMe && status != null)) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showTimestamp)
                                Text(
                                  _formatTime(timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSentByMe
                                        ? Colors.white.withAlpha((255 * 0.7).toInt())
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              if (isSentByMe && status != null) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  status!.icon,
                                  size: 14,
                                  color: Colors.white.withAlpha((255 * 0.7).toInt()),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar (for sent messages - optional)
          if (isSentByMe && showAvatar) ...[
            const SizedBox(width: AppSizes.spacingS),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primary,
      backgroundImage:
          senderAvatarUrl != null ? NetworkImage(senderAvatarUrl!) : null,
      child: senderAvatarUrl == null
          ? const Icon(
              Icons.person,
              size: 18,
              color: Colors.white,
            )
          : null,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      // Today: show only time
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else if (now.difference(time).inDays < 7) {
      // This week: show day name
      return DateFormat('EEE HH:mm').format(time);
    } else {
      // Older: show date
      return DateFormat('MMM dd').format(time);
    }
  }
}

/// Message Status
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

extension MessageStatusExtension on MessageStatus {
  IconData get icon {
    switch (this) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }
}

/// Typing Indicator
/// 
/// Shows when someone is typing
class TypingIndicator extends StatefulWidget {
  final String? senderName;

  const TypingIndicator({
    super.key,
    this.senderName,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.person,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.senderName != null) ...[
                  Text(
                    '${widget.senderName} is typing',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                ],
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final value = (_controller.value + delay) % 1.0;
                        final scale = value < 0.5
                            ? 1.0 + (value * 0.6)
                            : 1.3 - ((value - 0.5) * 0.6);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
