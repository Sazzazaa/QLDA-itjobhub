import 'dart:math';
import 'package:itjobhub/models/forum_model.dart';

/// Forum Service
/// Handles all forum-related operations including posts and comments
class ForumService {
  static final ForumService _instance = ForumService._internal();
  factory ForumService() => _instance;
  ForumService._internal();

  final List<ForumPost> _posts = [];
  final List<ForumComment> _comments = [];
  bool _isInitialized = false;

  // Initialize with mock data
  void initialize() {
    if (_isInitialized) return;
    _posts.addAll(_generateMockPosts());
    _comments.addAll(_generateMockComments());
    _isInitialized = true;
  }

  // Get all posts
  List<ForumPost> getAllPosts() {
    initialize();
    return List.from(_posts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get posts by category
  List<ForumPost> getPostsByCategory(PostCategory category) {
    initialize();
    return _posts
        .where((post) => post.category == category)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get user's posts
  List<ForumPost> getUserPosts(String userId) {
    initialize();
    return _posts
        .where((post) => post.authorId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get saved posts
  List<ForumPost> getSavedPosts(String userId) {
    initialize();
    return _posts
        .where((post) => post.isSavedBy(userId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get trending posts
  List<ForumPost> getTrendingPosts() {
    initialize();
    return _posts.where((post) => post.isTrending).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  // Get post by ID
  ForumPost? getPostById(String postId) {
    initialize();
    try {
      return _posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  // Search posts
  List<ForumPost> searchPosts(String query) {
    initialize();
    final lowerQuery = query.toLowerCase();
    return _posts.where((post) {
      return post.title.toLowerCase().contains(lowerQuery) ||
          post.content.toLowerCase().contains(lowerQuery) ||
          post.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Create new post
  ForumPost createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? authorRole,
    required String title,
    required String content,
    required PostCategory category,
    List<String> tags = const [],
    String? imageUrl,
  }) {
    final post = ForumPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorRole: authorRole,
      title: title,
      content: content,
      category: category,
      tags: tags,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
    );
    _posts.insert(0, post);
    return post;
  }

  // Update post
  ForumPost? updatePost(String postId, {
    String? title,
    String? content,
    PostCategory? category,
    List<String>? tags,
  }) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final updatedPost = _posts[index].copyWith(
      title: title,
      content: content,
      category: category,
      tags: tags,
      updatedAt: DateTime.now(),
    );
    _posts[index] = updatedPost;
    return updatedPost;
  }

  // Delete post
  bool deletePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;
    _posts.removeAt(index);
    // Also delete comments
    _comments.removeWhere((c) => c.postId == postId);
    return true;
  }

  // Upvote post
  ForumPost? upvotePost(String postId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final upvotedBy = List<String>.from(post.upvotedBy);
    final downvotedBy = List<String>.from(post.downvotedBy);
    
    // Remove from downvotes if exists
    downvotedBy.remove(userId);
    
    // Toggle upvote
    if (upvotedBy.contains(userId)) {
      upvotedBy.remove(userId);
    } else {
      upvotedBy.add(userId);
    }

    final updatedPost = post.copyWith(
      upvotedBy: upvotedBy,
      downvotedBy: downvotedBy,
      upvotes: upvotedBy.length,
      downvotes: downvotedBy.length,
    );
    _posts[index] = updatedPost;
    return updatedPost;
  }

  // Downvote post
  ForumPost? downvotePost(String postId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final upvotedBy = List<String>.from(post.upvotedBy);
    final downvotedBy = List<String>.from(post.downvotedBy);
    
    // Remove from upvotes if exists
    upvotedBy.remove(userId);
    
    // Toggle downvote
    if (downvotedBy.contains(userId)) {
      downvotedBy.remove(userId);
    } else {
      downvotedBy.add(userId);
    }

    final updatedPost = post.copyWith(
      upvotedBy: upvotedBy,
      downvotedBy: downvotedBy,
      upvotes: upvotedBy.length,
      downvotes: downvotedBy.length,
    );
    _posts[index] = updatedPost;
    return updatedPost;
  }

  // Save/unsave post
  ForumPost? toggleSavePost(String postId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final savedBy = List<String>.from(post.savedBy);
    
    if (savedBy.contains(userId)) {
      savedBy.remove(userId);
    } else {
      savedBy.add(userId);
    }

    final updatedPost = post.copyWith(savedBy: savedBy);
    _posts[index] = updatedPost;
    return updatedPost;
  }

  // Increment view count
  ForumPost? incrementViews(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final updatedPost = _posts[index].copyWith(
      viewsCount: _posts[index].viewsCount + 1,
    );
    _posts[index] = updatedPost;
    return updatedPost;
  }

  // ===== Comments =====

  // Get comments for a post
  List<ForumComment> getPostComments(String postId) {
    initialize();
    return _comments
        .where((c) => c.postId == postId && c.parentCommentId == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get replies to a comment
  List<ForumComment> getCommentReplies(String commentId) {
    initialize();
    return _comments
        .where((c) => c.parentCommentId == commentId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Create comment
  ForumComment createComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? authorRole,
    required String content,
    String? parentCommentId,
  }) {
    final comment = ForumComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorRole: authorRole,
      content: content,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
    _comments.add(comment);
    
    // Update post comment count
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        commentsCount: _posts[postIndex].commentsCount + 1,
      );
    }
    
    return comment;
  }

  // Delete comment
  bool deleteComment(String commentId) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return false;
    
    final comment = _comments[index];
    _comments.removeAt(index);
    
    // Update post comment count
    final postIndex = _posts.indexWhere((p) => p.id == comment.postId);
    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        commentsCount: max(0, _posts[postIndex].commentsCount - 1),
      );
    }
    
    return true;
  }

  // Upvote comment
  ForumComment? upvoteComment(String commentId, String userId) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return null;

    final comment = _comments[index];
    final upvotedBy = List<String>.from(comment.upvotedBy);
    final downvotedBy = List<String>.from(comment.downvotedBy);
    
    downvotedBy.remove(userId);
    
    if (upvotedBy.contains(userId)) {
      upvotedBy.remove(userId);
    } else {
      upvotedBy.add(userId);
    }

    final updatedComment = comment.copyWith(
      upvotedBy: upvotedBy,
      downvotedBy: downvotedBy,
      upvotes: upvotedBy.length,
      downvotes: downvotedBy.length,
    );
    _comments[index] = updatedComment;
    return updatedComment;
  }

  // Get category statistics
  List<CategoryStats> getCategoryStats() {
    initialize();
    return PostCategory.values.map((category) {
      final posts = getPostsByCategory(category);
      final todayPosts = posts.where((p) {
        final diff = DateTime.now().difference(p.createdAt);
        return diff.inHours < 24;
      }).length;
      
      return CategoryStats(
        category: category,
        postsCount: posts.length,
        todayPostsCount: todayPosts,
      );
    }).toList();
  }

  // ===== Mock Data Generation =====

  List<ForumPost> _generateMockPosts() {
    final now = DateTime.now();
    
    return [
      ForumPost(
        id: 'post_1',
        authorId: 'user_1',
        authorName: 'Sarah Johnson',
        authorRole: 'candidate',
        title: 'How I passed the Google technical interview',
        content: '''I just wanted to share my experience and tips for those preparing for technical interviews at big tech companies.

**Preparation Timeline:** 3 months
- Month 1: Data structures and algorithms fundamentals
- Month 2: Practice on LeetCode (300+ problems)
- Month 3: Mock interviews and system design

**Key Tips:**
1. Focus on understanding patterns, not memorizing solutions
2. Practice explaining your thought process out loud
3. Don't skip the behavioral questions preparation
4. Take care of your mental health during prep

**Interview Day:**
The interview was 4 rounds - 2 coding, 1 system design, and 1 behavioral. The interviewers were really friendly and gave hints when I was stuck.

Happy to answer any questions!''',
        category: PostCategory.interviewTips,
        tags: ['google', 'interview', 'big-tech', 'coding'],
        createdAt: now.subtract(const Duration(hours: 5)),
        upvotes: 142,
        downvotes: 3,
        commentsCount: 28,
        viewsCount: 856,
        upvotedBy: List.generate(142, (i) => 'user_$i'),
        downvotedBy: List.generate(3, (i) => 'user_${i + 200}'),
        isPinned: true,
        isFeatured: true,
      ),
      ForumPost(
        id: 'post_2',
        authorId: 'user_2',
        authorName: 'Mike Chen',
        authorRole: 'candidate',
        title: 'Remote work is changing tech careers forever',
        content: '''The shift to remote work has completely transformed how we approach our careers in tech. Here are some observations:

**Opportunities:**
- Access to global companies without relocating
- Better work-life balance
- Cost savings (no commute, can live anywhere)

**Challenges:**
- Harder to build relationships with team
- Communication can be tricky across time zones
- Missing the office environment

What's your experience with remote work? Is it here to stay?''',
        category: PostCategory.careerAdvice,
        tags: ['remote-work', 'career', 'work-life-balance'],
        createdAt: now.subtract(const Duration(hours: 12)),
        upvotes: 87,
        downvotes: 12,
        commentsCount: 34,
        viewsCount: 445,
        upvotedBy: List.generate(87, (i) => 'user_${i + 50}'),
        downvotedBy: List.generate(12, (i) => 'user_${i + 300}'),
      ),
      ForumPost(
        id: 'post_3',
        authorId: 'user_3',
        authorName: 'Emma Davis',
        authorRole: 'candidate',
        title: 'AI and Machine Learning: Should I learn it in 2025?',
        content: '''With all the buzz around AI, I'm wondering if I should pivot my career to focus on machine learning and AI.

Current background: 5 years as a full-stack developer (React + Node.js)

Questions:
1. Is AI/ML oversaturated now?
2. What's the best learning path?
3. Do I need a Master's degree?
4. Salary expectations for entry-level ML roles?

Would love to hear from people who made this transition!''',
        category: PostCategory.techTrends,
        tags: ['ai', 'machine-learning', 'career-change', 'advice'],
        createdAt: now.subtract(const Duration(days: 1)),
        upvotes: 56,
        downvotes: 4,
        commentsCount: 19,
        viewsCount: 312,
        upvotedBy: List.generate(56, (i) => 'user_${i + 100}'),
        downvotedBy: List.generate(4, (i) => 'user_${i + 400}'),
      ),
      ForumPost(
        id: 'post_4',
        authorId: 'user_4',
        authorName: 'Alex Kumar',
        authorRole: 'employer',
        title: 'What employers actually look for in junior developers',
        content: '''As a hiring manager at a mid-size startup, I want to share what really matters when we hire junior devs:

**Technical Skills (40%):**
- Problem-solving ability > memorizing syntax
- Understanding of fundamentals
- Ability to learn quickly

**Soft Skills (40%):**
- Communication (huge!)
- Teamwork and collaboration
- Taking feedback well

**Other (20%):**
- Portfolio/side projects
- Contributions to open source
- Cultural fit

**What doesn't matter as much:**
- Perfect GPA
- Knowing every framework
- Years of experience (for junior roles)

Focus on the fundamentals and being a good team player!''',
        category: PostCategory.careerAdvice,
        tags: ['hiring', 'junior-developer', 'career-tips'],
        createdAt: now.subtract(const Duration(days: 2)),
        upvotes: 203,
        downvotes: 8,
        commentsCount: 67,
        viewsCount: 1245,
        upvotedBy: List.generate(203, (i) => 'user_${i + 150}'),
        downvotedBy: List.generate(8, (i) => 'user_${i + 500}'),
        isFeatured: true,
      ),
      ForumPost(
        id: 'post_5',
        authorId: 'user_5',
        authorName: 'Jessica Brown',
        authorRole: 'candidate',
        title: 'Salary negotiation: I increased my offer by \$25K',
        content: '''Just accepted a new role and wanted to share my negotiation experience.

**Initial offer:** \$95K
**Final offer:** \$120K + RSUs

**What I did:**
1. Did market research (levels.fyi, Glassdoor)
2. Waited 24 hours before responding
3. Highlighted my unique skills
4. Was ready to walk away
5. Negotiated total comp, not just base

**Key lesson:** Companies expect you to negotiate. The worst they can say is no.

AMA about salary negotiation!''',
        category: PostCategory.salaryDiscussion,
        tags: ['salary', 'negotiation', 'compensation', 'career'],
        createdAt: now.subtract(const Duration(hours: 8)),
        upvotes: 178,
        downvotes: 5,
        commentsCount: 42,
        viewsCount: 923,
        upvotedBy: List.generate(178, (i) => 'user_${i + 200}'),
        downvotedBy: List.generate(5, (i) => 'user_${i + 600}'),
        isPinned: true,
      ),
      ForumPost(
        id: 'post_6',
        authorId: 'user_6',
        authorName: 'David Lee',
        authorRole: 'candidate',
        title: 'Should I take a pay cut for better work-life balance?',
        content: '''Current situation:
- Earning \$150K at a FAANG company
- Working 60-70 hours/week
- Stressed and burnt out

Got an offer from a smaller company:
- \$110K salary
- 40 hours/week
- Better culture
- More interesting work

Is the pay cut worth it? Has anyone made a similar move?''',
        category: PostCategory.qa,
        tags: ['work-life-balance', 'career-decision', 'salary'],
        createdAt: now.subtract(const Duration(hours: 18)),
        upvotes: 92,
        downvotes: 15,
        commentsCount: 53,
        viewsCount: 567,
        upvotedBy: List.generate(92, (i) => 'user_${i + 250}'),
        downvotedBy: List.generate(15, (i) => 'user_${i + 700}'),
      ),
    ];
  }

  List<ForumComment> _generateMockComments() {
    return [
      ForumComment(
        id: 'comment_1',
        postId: 'post_1',
        authorId: 'user_10',
        authorName: 'Tom Wilson',
        authorRole: 'candidate',
        content: 'This is super helpful! How many hours per day did you dedicate to LeetCode?',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        upvotes: 12,
        upvotedBy: List.generate(12, (i) => 'user_${i + 1000}'),
      ),
      ForumComment(
        id: 'comment_2',
        postId: 'post_1',
        authorId: 'user_1',
        authorName: 'Sarah Johnson',
        authorRole: 'candidate',
        content: 'About 2-3 hours on weekdays and 4-5 hours on weekends. Consistency is key!',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        upvotes: 8,
        upvotedBy: List.generate(8, (i) => 'user_${i + 1100}'),
      ),
      ForumComment(
        id: 'comment_3',
        postId: 'post_5',
        authorId: 'user_20',
        authorName: 'Rachel Green',
        authorRole: 'candidate',
        content: 'Wow, congrats! Did you provide proof of competing offers?',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        upvotes: 15,
        upvotedBy: List.generate(15, (i) => 'user_${i + 1200}'),
      ),
    ];
  }
}
