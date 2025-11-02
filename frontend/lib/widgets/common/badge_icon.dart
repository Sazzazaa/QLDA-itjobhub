import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Badge Icon
/// 
/// Displays an achievement badge
/// 
/// Example:
/// ```dart
/// BadgeIcon(
///   icon: Icons.star,
///   label: 'Expert',
///   isEarned: true,
/// )
/// ```
class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEarned;
  final Color? color;
  final double size;
  final VoidCallback? onTap;
  final String? description;
  final int? progress; // 0-100
  final int? target;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.label,
    this.isEarned = false,
    this.color,
    this.size = 64,
    this.onTap,
    this.description,
    this.progress,
    this.target,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isEarned
        ? (color ?? AppColors.premiumGold)
        : AppColors.textHint;

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: description ?? label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badgeColor.withAlpha((255 * 0.1).toInt()),
                    border: Border.all(
                      color: badgeColor,
                      width: isEarned ? 3 : 2,
                    ),
                    boxShadow: isEarned
                        ? [
                            BoxShadow(
                              color: badgeColor.withAlpha((255 * 0.3).toInt()),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: size * 0.5,
                      color: badgeColor,
                    ),
                  ),
                ),

                // Locked overlay
                if (!isEarned)
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha((255 * 0.3).toInt()),
                    ),
                    child: Icon(
                      Icons.lock,
                      size: size * 0.3,
                      color: Colors.white,
                    ),
                  ),

                // Progress indicator
                if (progress != null && !isEarned)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$progress%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingS),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isEarned ? FontWeight.w600 : FontWeight.w400,
                color: isEarned ? badgeColor : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress text
            if (target != null && !isEarned) ...[
              const SizedBox(height: 2),
              Text(
                '${progress ?? 0}/$target',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Badge Card
/// 
/// Larger badge display with description
class BadgeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isEarned;
  final DateTime? earnedDate;
  final Color? color;

  const BadgeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isEarned = false,
    this.earnedDate,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isEarned
        ? (color ?? AppColors.premiumGold)
        : AppColors.textHint;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Row(
          children: [
            // Badge icon
            BadgeIcon(
              icon: icon,
              label: '',
              isEarned: isEarned,
              color: color,
              size: 64,
            ),
            const SizedBox(width: AppSizes.spacingL),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isEarned)
                        Icon(
                          Icons.verified,
                          color: badgeColor,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isEarned && earnedDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Earned ${_formatDate(earnedDate!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
