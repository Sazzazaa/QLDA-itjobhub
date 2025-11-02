import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_constants.dart';

/// Rating Display Widget
/// 
/// Shows a read-only star rating
/// 
/// Example:
/// ```dart
/// RatingDisplay(
///   rating: 4.5,
///   reviewCount: 120,
/// )
/// ```
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;
  final Color? color;
  final bool showCount;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16.0,
    this.color,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: color ?? AppColors.warning,
          ),
          itemCount: 5,
          itemSize: size,
          unratedColor: AppColors.divider,
        ),
        if (showCount && reviewCount != null) ...[
          const SizedBox(width: AppSizes.spacingS),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.875, // Slightly smaller than star size
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Rating Input Widget
/// 
/// Interactive star rating for user input
/// 
/// Example:
/// ```dart
/// RatingInput(
///   initialRating: 4.0,
///   onRatingUpdate: (rating) {
///     print('New rating: $rating');
///   },
/// )
/// ```
class RatingInput extends StatelessWidget {
  final double initialRating;
  final ValueChanged<double> onRatingUpdate;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final String? label;

  const RatingInput({
    super.key,
    this.initialRating = 0.0,
    required this.onRatingUpdate,
    this.size = 32.0,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],
        RatingBar.builder(
          initialRating: initialRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: allowHalfRating,
          itemCount: 5,
          itemSize: size,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: activeColor ?? AppColors.warning,
          ),
          unratedColor: inactiveColor ?? AppColors.divider,
          onRatingUpdate: onRatingUpdate,
          glow: true,
          glowColor: (activeColor ?? AppColors.warning).withAlpha((255 * 0.3).toInt()),
        ),
      ],
    );
  }
}

/// Rating Card
/// 
/// Complete rating card with stars, average, and review count
class RatingCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int>? starDistribution; // star number -> count
  final VoidCallback? onViewAllReviews;

  const RatingCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    this.starDistribution,
    this.onViewAllReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAllReviews != null)
                  TextButton(
                    onPressed: onViewAllReviews,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Average Rating Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingDisplay(
                      rating: averageRating,
                      reviewCount: null,
                      size: 20,
                      showCount: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews reviews',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Star Distribution
            if (starDistribution != null) ...[
              const SizedBox(height: AppSizes.spacingL),
              ...List.generate(5, (index) {
                final starNumber = 5 - index;
                final count = starDistribution![starNumber] ?? 0;
                final percentage = totalReviews > 0
                    ? (count / totalReviews * 100).toInt()
                    : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                  child: Row(
                    children: [
                      Text(
                        '$starNumber',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.warning,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
