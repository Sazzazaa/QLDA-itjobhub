import 'package:intl/intl.dart';

/// Forum Post Category
enum PostCategory {
  interviewTips,
  techTrends,
  careerAdvice,
  salaryDiscussion,
  qa,
  general;

  String get displayName {
    switch (this) {
      case PostCategory.interviewTips:
        return 'Interview Tips';
      case PostCategory.techTrends:
        return 'Tech Trends';
      case PostCategory.careerAdvice:
        return 'Career Advice';
      case PostCategory.salaryDiscussion:
        return 'Salary Discussion';
      case PostCategory.qa:
        return 'Q&A';
      case PostCategory.general:
        return 'General';
    }
  }

  String get icon {
    switch (this) {
      case PostCategory.interviewTips:
        return '💼';
      case PostCategory.techTrends:
        return '🚀';
      case PostCategory.careerAdvice:
        return '🎯';
      case PostCategory.salaryDiscussion:
        return '💰';
      case PostCategory.qa:
        return '❓';
      case PostCategory.general:
        return '💬';
    }
  }
}

/// Forum Post Model
class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? authorRole; // 'candidate' or 'employer'
  final String title;
  final String content;
  final PostCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int upvotes;
  final int downvotes;
  final int commentsCount;
  final int viewsCount;
  final List<String> upvotedBy; // User IDs who upvoted
  final List<String> downvotedBy; // User IDs who downvoted
  final List<String> savedBy; // User IDs who saved this post
  final bool isPinned;
  final bool isFeatured;
  final String? imageUrl;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.authorRole,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.savedBy = const [],
    this.isPinned = false,
    this.isFeatured = false,
    this.imageUrl,
  });

  // Calculate net score
  int get score => upvotes - downvotes;

  // Check if user has upvoted
  bool hasUpvoted(String userId) => upvotedBy.contains(userId);

  // Check if user has downvoted
  bool hasDownvoted(String userId) => downvotedBy.contains(userId);

  // Check if user has saved
  bool isSavedBy(String userId) => savedBy.contains(userId);

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(createdAt);
    }
  }

  // Get content preview (first 150 chars)
  String get contentPreview {
    if (content.length <= 150) return content;
    return '${content.substring(0, 150)}...';
  }

  // Check if post is trending (high engagement recently)
  bool get isTrending {
    final hoursSinceCreated = DateTime.now().difference(createdAt).inHours;
    if (hoursSinceCreated > 48) return false;
    
    final engagementScore = (upvotes * 2) + commentsCount + (viewsCount ~/ 10);
    return engagementScore > 50;
  }

  // Copy with method
  ForumPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? authorRole,
    String? title,
    String? content,
    PostCategory? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    int? downvotes,
    int? commentsCount,
    int? viewsCount,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    List<String>? savedBy,
    bool? isPinned,
    bool? isFeatured,
    String? imageUrl,
  }) {
    return ForumPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorRole: authorRole ?? this.authorRole,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      savedBy: savedBy ?? this.savedBy,
      isPinned: isPinned ?? this.isPinned,
      isFeatured: isFeatured ?? this.isFeatured,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Comment Model
class ForumComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? authorRole;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final String? parentCommentId; // For nested replies
  final List<ForumComment> replies; // Nested replies

  ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.authorRole,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.parentCommentId,
    this.replies = const [],
  });

  // Calculate net score
  int get score => upvotes - downvotes;

  // Check if user has upvoted
  bool hasUpvoted(String userId) => upvotedBy.contains(userId);

  // Check if user has downvoted
  bool hasDownvoted(String userId) => downvotedBy.contains(userId);

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(createdAt);
    }
  }

  // Copy with method
  ForumComment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? authorRole,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    String? parentCommentId,
    List<ForumComment>? replies,
  }) {
    return ForumComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorRole: authorRole ?? this.authorRole,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
    );
  }
}

/// Category Statistics Model
class CategoryStats {
  final PostCategory category;
  final int postsCount;
  final int todayPostsCount;

  CategoryStats({
    required this.category,
    required this.postsCount,
    required this.todayPostsCount,
  });
}
