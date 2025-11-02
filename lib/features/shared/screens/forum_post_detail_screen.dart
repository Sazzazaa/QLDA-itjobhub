import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/forum_model.dart';
import 'package:itjobhub/services/forum_service.dart';

/// Forum Post Detail Screen
/// Shows full post content with comments and interactions
class ForumPostDetailScreen extends StatefulWidget {
  final ForumPost post;

  const ForumPostDetailScreen({super.key, required this.post});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _commentController = TextEditingController();
  final String _currentUserId = 'user_1'; // TODO: Get from auth
  final String _currentUserName = 'John Doe'; // TODO: Get from auth

  late ForumPost _post;
  List<ForumComment> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _forumService.initialize();
    _forumService.incrementViews(_post.id);
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    setState(() => _isLoadingComments = true);
    _comments = _forumService.getPostComments(_post.id);
    setState(() => _isLoadingComments = false);
  }

  void _refreshPost() {
    final updatedPost = _forumService.getPostById(_post.id);
    if (updatedPost != null) {
      setState(() => _post = updatedPost);
    }
  }

  void _handleUpvote() {
    _forumService.upvotePost(_post.id, _currentUserId);
    _refreshPost();
  }

  void _handleSave() {
    _forumService.toggleSavePost(_post.id, _currentUserId);
    _refreshPost();
  }

  void _handleShare() {
    Clipboard.setData(
      ClipboardData(
        text: '${_post.title}\n\n${_post.contentPreview}\n\nShared from IT Job Finder Community',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post link copied to clipboard!')),
    );
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;

    _forumService.createComment(
      postId: _post.id,
      authorId: _currentUserId,
      authorName: _currentUserName,
      authorRole: 'candidate',
      content: _commentController.text.trim(),
    );

    _commentController.clear();
    _loadComments();
    _refreshPost();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment posted!')),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _forumService.deletePost(_post.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to forum
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_post.authorId == _currentUserId)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Post', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Content
                  _buildPostContent(),

                  const Divider(height: 1, thickness: 1),

                  // Comments Section
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),

          // Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  _post.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _post.formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_post.category.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      _post.category.displayName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            _post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            _post.content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Tags
          if (_post.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),

          // Interaction Bar
          Row(
            children: [
              // Upvote
              _ActionButton(
                icon: Icons.arrow_upward,
                label: _post.score.toString(),
                isActive: _post.hasUpvoted(_currentUserId),
                color: AppColors.success,
                onTap: _handleUpvote,
              ),
              const SizedBox(width: 16),
              // Comments
              _ActionButton(
                icon: Icons.comment_outlined,
                label: _post.commentsCount.toString(),
                isActive: false,
                onTap: () {}, // Scroll to comments
              ),
              const SizedBox(width: 16),
              // Views
              Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _post.viewsCount.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              // Share
              IconButton(
                icon: Icon(Icons.share_outlined, color: Colors.grey[700]),
                onPressed: _handleShare,
              ),
              // Save
              IconButton(
                icon: Icon(
                  _post.isSavedBy(_currentUserId)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: _post.isSavedBy(_currentUserId)
                      ? AppColors.primary
                      : Colors.grey[700],
                ),
                onPressed: _handleSave,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments (${_post.commentsCount})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingComments)
            const Center(child: CircularProgressIndicator())
          else if (_comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.comment_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No comments yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to comment!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._comments.map((comment) => _CommentCard(
                  comment: comment,
                  currentUserId: _currentUserId,
                  onDeleted: () {
                    _loadComments();
                    _refreshPost();
                  },
                )),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                _currentUserName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _postComment,
              icon: const Icon(Icons.send, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isActive ? (color ?? AppColors.primary) : Colors.grey[700];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (color ?? AppColors.primary).withValues(alpha: 0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: displayColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: displayColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final ForumComment comment;
  final String currentUserId;
  final VoidCallback onDeleted;

  const _CommentCard({
    required this.comment,
    required this.currentUserId,
    required this.onDeleted,
  });

  void _deleteComment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ForumService().deleteComment(comment.id);
              Navigator.pop(context);
              onDeleted();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comment deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _upvoteComment() {
    ForumService().upvoteComment(comment.id, currentUserId);
    onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  comment.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      comment.formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (comment.authorId == currentUserId)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.grey[600],
                  onPressed: () => _deleteComment(context),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _upvoteComment,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: comment.hasUpvoted(currentUserId)
                          ? AppColors.success
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.score.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: comment.hasUpvoted(currentUserId)
                            ? AppColors.success
                            : Colors.grey[600],
                        fontWeight: comment.hasUpvoted(currentUserId)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
