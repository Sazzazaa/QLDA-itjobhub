import 'package:itjobhub/models/message_model.dart';
import 'package:itjobhub/models/conversation_model.dart';
import 'api_client.dart';

/// Message Service
/// 
/// Manages conversations and messages with API integration
class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final ApiClient _apiClient = ApiClient();
  
  // Cache storage
  final List<Conversation> _conversations = [];
  final Map<String, List<Message>> _messagesByConversation = {};
  
  // Current user ID (from auth service)
  String _currentUserId = '';
  // ignore: unused_field
  String _currentUserName = '';
  // ignore: unused_field
  String _currentUserRole = 'candidate'; // 'candidate' or 'employer'

  /// Initialize service with user data
  void initialize({
    required String userId,
    required String userName,
    required String userRole,
  }) {
    _currentUserId = userId;
    _currentUserName = userName;
    _currentUserRole = userRole;
    print('💬 MessageService: Initialized for user $userName ($userRole)');
  }

  /// Get all conversations for current user
  Future<List<Conversation>> getConversations() async {
    try {
      print('💬 MessageService: Fetching conversations from API...');
      final response = await _apiClient.get('/messages/conversations');
      
      print('💬 MessageService: Raw API response type: ${response.runtimeType}');
      if (response is List) {
        print('💬 MessageService: Response is a list with ${response.length} items');
        if (response.isNotEmpty) {
          print('💬 MessageService: First item: ${response.first}');
        }
      } else {
        print('💬 MessageService: Response is NOT a list: $response');
      }
      
      _conversations.clear();
      _conversations.addAll(
        (response as List).map((json) => Conversation.fromJson(json)).toList(),
      );
      
      print('✅ MessageService: Loaded ${_conversations.length} conversations');
      return List.from(_conversations)
        ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    } catch (e, stackTrace) {
      print('❌ MessageService: Failed to fetch conversations - $e');
      print('Stack trace: $stackTrace');
      // Return cached conversations on error
      return List.from(_conversations)
        ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    }
  }

  /// Get messages for a specific conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      print('💬 MessageService: Fetching messages for conversation $conversationId...');
      final response = await _apiClient.get('/messages/conversations/$conversationId/messages');
      
      final messages = (response as List)
          .map((json) => Message.fromJson(json))
          .toList();
      
      _messagesByConversation[conversationId] = messages;
      
      print('✅ MessageService: Loaded ${messages.length} messages');
      return messages;
    } catch (e) {
      print('❌ MessageService: Failed to fetch messages - $e');
      return _messagesByConversation[conversationId] ?? [];
    }
  }

  /// Get a specific conversation by ID
  Conversation? getConversation(String conversationId) {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  /// Get or create conversation with a specific user about a job
  Future<Conversation> getOrCreateConversation({
    required String participantId,
    required String participantName,
    required String participantRole,
    String? participantAvatarUrl,
    String? jobId,
    String? jobTitle,
  }) async {
    try {
      print('💬 MessageService: Getting/creating conversation with $participantName...');
      
      final response = await _apiClient.post('/messages/conversations', {
        'participantId': participantId,
        if (jobId != null) 'jobId': jobId,
      });

      final conversation = Conversation.fromJson(response);
      
      // Update cache
      final existingIndex = _conversations.indexWhere((c) => c.id == conversation.id);
      if (existingIndex >= 0) {
        _conversations[existingIndex] = conversation;
      } else {
        _conversations.add(conversation);
      }
      
      print('✅ MessageService: Conversation ready - ${conversation.id}');
      return conversation;
    } catch (e) {
      print('❌ MessageService: Failed to get/create conversation - $e');
      rethrow;
    }
  }

  /// Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      print('💬 MessageService: Sending message...');
      
      final response = await _apiClient.post(
        '/messages/conversations/$conversationId/messages',
        {'text': text},
      );

      final message = Message.fromJson(response);

      // Update local cache
      if (_messagesByConversation.containsKey(conversationId)) {
        _messagesByConversation[conversationId]!.add(message);
      } else {
        _messagesByConversation[conversationId] = [message];
      }

      // Update conversation's last activity
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex >= 0) {
        _conversations[convIndex] = _conversations[convIndex].copyWith(
          lastMessage: message,
          lastActivity: message.timestamp,
        );
      }

      print('✅ MessageService: Message sent');
      return message;
    } catch (e) {
      print('❌ MessageService: Failed to send message - $e');
      rethrow;
    }
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      print('💬 MessageService: Marking conversation as read...');
      
      await _apiClient.put('/messages/conversations/$conversationId/read', {});

      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
          unreadCount: 0,
        );
      }

      // Mark all messages as read
      final messages = _messagesByConversation[conversationId] ?? [];
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].senderId != _currentUserId && !messages[i].isRead) {
          messages[i] = messages[i].copyWith(isRead: true);
        }
      }
      
      print('✅ MessageService: Marked as read');
    } catch (e) {
      print('❌ MessageService: Failed to mark as read - $e');
    }
  }

  /// Get total unread count across all conversations
  int getTotalUnreadCount() {
    return _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      print('💬 MessageService: Deleting conversation...');
      
      await _apiClient.delete('/messages/conversations/$conversationId');

      _conversations.removeWhere((c) => c.id == conversationId);
      _messagesByConversation.remove(conversationId);
      
      print('✅ MessageService: Conversation deleted');
    } catch (e) {
      print('❌ MessageService: Failed to delete conversation - $e');
    }
  }

  /// Search conversations (local search)
  Future<List<Conversation>> searchConversations(String query) async {
    if (query.isEmpty) return await getConversations();

    final lowerQuery = query.toLowerCase();
    return _conversations.where((conv) {
      return conv.participantName.toLowerCase().contains(lowerQuery) ||
          (conv.jobTitle?.toLowerCase().contains(lowerQuery) ?? false) ||
          (conv.lastMessage?.text.toLowerCase().contains(lowerQuery) ?? false);
    }).toList()
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  /// Clear all data (for testing/logout)
  void clear() {
    _conversations.clear();
    _messagesByConversation.clear();
  }
}
