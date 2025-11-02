import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/review_model.dart';
import 'package:itjobhub/services/review_service.dart';
import 'package:itjobhub/features/shared/screens/write_company_review_screen.dart';

/// Company Reviews Screen
/// 
/// Displays all reviews for a specific company with filtering and sorting
class CompanyReviewsScreen extends StatefulWidget {
  final String companyId;
  final String companyName;

  const CompanyReviewsScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<CompanyReviewsScreen> createState() => _CompanyReviewsScreenState();
}

class _CompanyReviewsScreenState extends State<CompanyReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  
  List<CompanyReview> _reviews = [];
  ReviewStatistics? _statistics;
  ReviewSortOption _sortOption = ReviewSortOption.mostRecent;
  int? _filterRating;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reviewService.initialize();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() => _isLoading = true);
    
    // Get reviews and statistics
    final allReviews = _reviewService.getCompanyReviews(widget.companyId);
    _statistics = _reviewService.getCompanyReviewStatistics(widget.companyId);
    
    // Apply filters and sorting
    var filtered = _reviewService.filterCompanyReviewsByRating(allReviews, _filterRating);
    _reviews = _reviewService.sortCompanyReviews(filtered, _sortOption);
    
    setState(() => _isLoading = false);
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ReviewSortOption.values.map((option) => RadioListTile<ReviewSortOption>(
              title: Text(option.displayName),
              value: option,
              groupValue: _sortOption,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOption = value);
                  _loadReviews();
                  Navigator.pop(context);
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter By Rating',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<int?>(
              title: const Text('All Ratings'),
              value: null,
              groupValue: _filterRating,
              onChanged: (value) {
                setState(() => _filterRating = value);
                _loadReviews();
                Navigator.pop(context);
              },
            ),
            ...List.generate(5, (index) => 5 - index).map((stars) => RadioListTile<int>(
              title: Row(
                children: [
                  Text('$stars'),
                  const SizedBox(width: 4),
                  ...List.generate(stars, (_) => const Icon(Icons.star, size: 16, color: AppColors.warning)),
                  const Text(' & up'),
                ],
              ),
              value: stars,
              groupValue: _filterRating,
              onChanged: (value) {
                setState(() => _filterRating = value);
                _loadReviews();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToWriteReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteCompanyReviewScreen(
          companyId: widget.companyId,
          companyName: widget.companyName,
        ),
      ),
    );
    
    if (result == true) {
      _loadReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.companyName} Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (_statistics != null) _buildStatisticsHeader(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reviews.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _ReviewCard(
                          review: _reviews[index],
                          onHelpful: (reviewId) async {
                            await _reviewService.markReviewHelpful(reviewId, 'current_user_id');
                            _loadReviews();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToWriteReview,
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    final stats = _statistics!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Average Rating
          Row(
            children: [
              Column(
                children: [
                  Text(
                    stats.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < stats.averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stats.totalReviews} ${stats.totalReviews == 1 ? 'review' : 'reviews'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final stars = 5 - index;
                    final percentage = stats.getPercentageForRating(stars);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$stars',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 12, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 35,
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Recommend Percentage
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thumb_up, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${stats.recommendPercentage}% would recommend',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Reviews Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to review ${widget.companyName}',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToWriteReview,
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CompanyReview review;
  final Function(String) onHelpful;

  const _ReviewCard({
    required this.review,
    required this.onHelpful,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: review.isAnonymous
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : Text(
                          review.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (review.isCurrentEmployee) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Current Employee',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.formattedDate,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      review.overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: AppColors.warning, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title
            if (review.title != null) ...[
              Text(
                review.title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Review Text
            Text(
              review.reviewText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            
            // Pros & Cons
            if (review.pros != null || review.cons != null) ...[
              const SizedBox(height: 12),
              if (review.pros != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.add_circle, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.pros!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (review.cons != null) const SizedBox(height: 8),
              ],
              if (review.cons != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.remove_circle, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.cons!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
            ],
            
            const SizedBox(height: 12),
            const Divider(),
            
            // Helpful Button
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => onHelpful(review.id),
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful (${review.helpfulCount})'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
