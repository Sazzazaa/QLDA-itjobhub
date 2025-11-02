import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/forum_model.dart';
import 'package:itjobhub/services/forum_service.dart';
import 'package:itjobhub/features/shared/screens/forum_post_detail_screen.dart';
import 'package:itjobhub/features/shared/screens/create_post_screen.dart';

/// Forum Home Screen
/// Main screen for the community forum with categories, tabs, and posts
class ForumHomeScreen extends StatefulWidget {
  const ForumHomeScreen({super.key});

  @override
  State<ForumHomeScreen> createState() => _ForumHomeScreenState();
}

class _ForumHomeScreenState extends State<ForumHomeScreen>
    with SingleTickerProviderStateMixin {
  final ForumService _forumService = ForumService();
  late TabController _tabController;
  final String _currentUserId = 'user_1'; // TODO: Get from auth

  List<ForumPost> _posts = [];
  bool _isLoading = false;
  PostCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _forumService.initialize();
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadPosts();
  }

  void _loadPosts() {
    setState(() => _isLoading = true);

    List<ForumPost> posts;
    switch (_tabController.index) {
      case 0: // All Posts
        posts = _selectedCategory == null
            ? _forumService.getAllPosts()
            : _forumService.getPostsByCategory(_selectedCategory!);
        break;
      case 1: // My Posts
        posts = _forumService.getUserPosts(_currentUserId);
        break;
      case 2: // Saved
        posts = _forumService.getSavedPosts(_currentUserId);
        break;
      case 3: // Trending
        posts = _forumService.getTrendingPosts();
        break;
      default:
        posts = _forumService.getAllPosts();
    }

    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );
    if (result == true) {
      _loadPosts();
    }
  }

  void _navigateToPostDetail(ForumPost post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumPostDetailScreen(post: post),
      ),
    );
    _loadPosts(); // Refresh in case post was updated
  }

  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: PostSearchDelegate(_forumService, _navigateToPostDetail),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Community Forum'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'My Posts'),
            Tab(text: 'Saved'),
            Tab(text: 'Trending'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index == 0) _buildCategoriesSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async => _loadPosts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return _PostCard(
                              post: _posts[index],
                              currentUserId: _currentUserId,
                              onTap: () => _navigateToPostDetail(_posts[index]),
                              onVoteChanged: () => _loadPosts(),
                              onSaveChanged: () => _loadPosts(),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePost,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                category: null,
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  _loadPosts();
                },
              ),
              ...PostCategory.values.map((category) {
                return _CategoryChip(
                  category: category,
                  isSelected: _selectedCategory == category,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    _loadPosts();
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 1:
        message = 'You haven\'t created any posts yet';
        icon = Icons.post_add;
        break;
      case 2:
        message = 'No saved posts';
        icon = Icons.bookmark_border;
        break;
      case 3:
        message = 'No trending posts right now';
        icon = Icons.trending_up;
        break;
      default:
        message = 'No posts available';
        icon = Icons.forum;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final PostCategory? category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = category?.displayName ?? 'All';
    final icon = category?.icon ?? '📋';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ForumPost post;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onVoteChanged;
  final VoidCallback onSaveChanged;

  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onTap,
    required this.onVoteChanged,
    required this.onSaveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final forumService = ForumService();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author and Category
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      post.authorName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          post.formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.category.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          post.category.displayName,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content Preview
              Text(
                post.contentPreview,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (post.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),

              // Interaction Bar
              Row(
                children: [
                  // Upvote
                  _InteractionButton(
                    icon: Icons.arrow_upward,
                    label: post.score.toString(),
                    isActive: post.hasUpvoted(currentUserId),
                    color: AppColors.success,
                    onTap: () {
                      forumService.upvotePost(post.id, currentUserId);
                      onVoteChanged();
                    },
                  ),
                  const SizedBox(width: 16),
                  // Comments
                  _InteractionButton(
                    icon: Icons.comment_outlined,
                    label: post.commentsCount.toString(),
                    isActive: false,
                    onTap: onTap,
                  ),
                  const SizedBox(width: 16),
                  // Views
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        post.viewsCount.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Save
                  IconButton(
                    icon: Icon(
                      post.isSavedBy(currentUserId)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: post.isSavedBy(currentUserId)
                          ? AppColors.primary
                          : Colors.grey[600],
                    ),
                    onPressed: () {
                      forumService.toggleSavePost(post.id, currentUserId);
                      onSaveChanged();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isActive ? (color ?? AppColors.primary) : Colors.grey[600];

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: displayColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: displayColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Search Delegate
class PostSearchDelegate extends SearchDelegate<ForumPost?> {
  final ForumService forumService;
  final Function(ForumPost) onPostSelected;

  PostSearchDelegate(this.forumService, this.onPostSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = forumService.searchPosts(query);
    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for posts, topics, or tags'));
    }
    final results = forumService.searchPosts(query);
    return _buildSearchResults(results);
  }

  Widget _buildSearchResults(List<ForumPost> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No posts found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(
            post.contentPreview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(post.category.icon),
          ),
          onTap: () {
            close(context, post);
            onPostSelected(post);
          },
        );
      },
    );
  }
}
