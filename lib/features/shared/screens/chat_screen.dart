import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/conversation_model.dart';
import 'package:itjobhub/models/message_model.dart';
import 'package:itjobhub/services/message_service.dart';
import 'package:itjobhub/services/auth_service.dart';
import 'package:itjobhub/widgets/common/chat_bubble.dart';
import 'package:itjobhub/widgets/common/chat_input_bar.dart';

/// Chat Screen
///
/// Displays a 1-on-1 conversation with message history and input
class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _markAsRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _currentUserId = user['_id']?.toString() ?? user['id']?.toString();
        });
        print('✅ ChatScreen: Current user ID = $_currentUserId');
      }
    } catch (e) {
      print('❌ ChatScreen: Failed to get current user - $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      print('💬 ChatScreen: Loading messages from API...');
      final messages = await _messageService.getMessages(widget.conversation.id);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        print('✅ ChatScreen: Loaded ${messages.length} messages');

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      print('❌ ChatScreen: Failed to load messages - $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead() async {
    await _messageService.markConversationAsRead(widget.conversation.id);
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      print('💬 ChatScreen: Sending message...');
      await _messageService.sendMessage(
        conversationId: widget.conversation.id,
        text: text,
      );

      if (mounted) {
        // Reload messages from service to get the updated list
        print('💬 ChatScreen: Reloading messages after send...');
        final messages = await _messageService.getMessages(widget.conversation.id);
        setState(() {
          _messages = messages;
          _isSending = false;
        });
        print('✅ ChatScreen: Message sent successfully');

        // Scroll to bottom to show new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('❌ ChatScreen: Failed to send message - $e');
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.conversation.participantInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.participantName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.conversation.jobTitle != null)
                    Text(
                      widget.conversation.jobTitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSentByMe = message.senderId == _currentUserId;
                      final showAvatar = !isSentByMe;

                      return ChatBubble(
                        message: message.text,
                        isSentByMe: isSentByMe,
                        timestamp: message.timestamp,
                        status: isSentByMe ? message.status : null,
                        senderName: showAvatar ? message.senderName : null,
                        showAvatar: showAvatar,
                        showTimestamp: true,
                      );
                    },
                  ),
          ),

          // Input bar
          ChatInputBar(
            controller: _textController,
            onSendMessage: _sendMessage,
            enabled: !_isSending,
            hintText: 'Type a message...',
            showAttachmentButton: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Start the conversation',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              'Say hi to ${widget.conversation.participantName}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Conversation Info'),
              onTap: () {
                Navigator.pop(context);
                _showConversationInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Conversation',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversation Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Name', value: widget.conversation.participantName),
            const SizedBox(height: AppSizes.spacingM),
            _InfoRow(
              label: 'Role',
              value: widget.conversation.participantRole == 'employer'
                  ? 'Employer'
                  : 'Candidate',
            ),
            if (widget.conversation.jobTitle != null) ...[
              const SizedBox(height: AppSizes.spacingM),
              _InfoRow(label: 'Job', value: widget.conversation.jobTitle!),
            ],
            const SizedBox(height: AppSizes.spacingM),
            _InfoRow(label: 'Messages', value: '${_messages.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _messageService.deleteConversation(widget.conversation.id);
      if (mounted) {
        Navigator.pop(context, true); // Return to conversations list
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
