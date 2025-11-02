import 'message_model.dart';

/// Conversation Model
/// 
/// Represents a conversation between two users
class Conversation {
  final String id;
  final String participantId; // The other user's ID
  final String participantName;
  final String? participantAvatarUrl;
  final String participantRole; // 'candidate' or 'employer'
  final String? jobId; // Related job if applicable
  final String? jobTitle; // Related job title if applicable
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final bool isActive;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatarUrl,
    required this.participantRole,
    this.jobId,
    this.jobTitle,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
    this.isActive = true,
  });

  Conversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatarUrl,
    String? participantRole,
    String? jobId,
    String? jobTitle,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    bool? isActive,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatarUrl: participantAvatarUrl ?? this.participantAvatarUrl,
      participantRole: participantRole ?? this.participantRole,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatarUrl': participantAvatarUrl,
      'participantRole': participantRole,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Parse lastActivity - handle both string and timestamp
    DateTime lastActivity = DateTime.now();
    if (json['lastActivity'] != null) {
      if (json['lastActivity'] is String) {
        lastActivity = DateTime.parse(json['lastActivity']);
      } else if (json['lastActivity'] is int) {
        lastActivity = DateTime.fromMillisecondsSinceEpoch(json['lastActivity']);
      }
    }
    
    return Conversation(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      participantName: json['participantName'] as String? ?? 'Unknown',
      participantAvatarUrl: json['participantAvatarUrl'] as String?,
      participantRole: json['participantRole'] as String? ?? 'candidate',
      jobId: json['jobId']?.toString(),
      jobTitle: json['jobTitle'] as String?,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastActivity: lastActivity,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Get initials from participant name for avatar
  String get participantInitials {
    return participantName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }
}
