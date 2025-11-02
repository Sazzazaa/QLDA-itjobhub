import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Match Percentage Card
/// 
/// Displays AI job matching score with breakdown
/// 
/// Example:
/// ```dart
/// MatchPercentageCard(
///   percentage: 85,
///   matchedSkills: ['Flutter', 'Dart', 'Firebase'],
///   missingSkills: ['GraphQL'],
/// )
/// ```
class MatchPercentageCard extends StatelessWidget {
  final int percentage;
  final List<String>? matchedSkills;
  final List<String>? missingSkills;
  final String? title;
  final VoidCallback? onViewDetails;
  final bool showBreakdown;

  const MatchPercentageCard({
    super.key,
    required this.percentage,
    this.matchedSkills,
    this.missingSkills,
    this.title,
    this.onViewDetails,
    this.showBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    final matchLevel = _getMatchLevel(percentage);

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
                Text(
                  title ?? 'Job Match',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('Details'),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Percentage display
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 8,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            matchLevel.color,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: matchLevel.color,
                            ),
                          ),
                          Text(
                            matchLevel.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.spacingL),

                // Match description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        matchLevel.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (matchedSkills != null &&
                          matchedSkills!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          '${matchedSkills!.length} skills matched',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Skill breakdown
            if (showBreakdown &&
                (matchedSkills != null || missingSkills != null)) ...[
              const SizedBox(height: AppSizes.spacingL),
              const Divider(),
              const SizedBox(height: AppSizes.spacingM),

              if (matchedSkills != null && matchedSkills!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    const Text(
                      'Matched Skills',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingS),
                Wrap(
                  spacing: AppSizes.spacingS,
                  runSpacing: AppSizes.spacingS,
                  children: matchedSkills!
                      .map((skill) => _SkillChip(
                            label: skill,
                            isMatched: true,
                          ))
                      .toList(),
                ),
              ],

              if (missingSkills != null && missingSkills!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingM),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    const Text(
                      'Skills to Learn',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingS),
                Wrap(
                  spacing: AppSizes.spacingS,
                  runSpacing: AppSizes.spacingS,
                  children: missingSkills!
                      .map((skill) => _SkillChip(
                            label: skill,
                            isMatched: false,
                          ))
                      .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  MatchLevel _getMatchLevel(int percentage) {
    if (percentage >= 80) {
      return MatchLevel.excellent;
    } else if (percentage >= 60) {
      return MatchLevel.good;
    } else if (percentage >= 40) {
      return MatchLevel.fair;
    } else {
      return MatchLevel.poor;
    }
  }
}

/// Match Level
enum MatchLevel {
  excellent,
  good,
  fair,
  poor,
}

extension MatchLevelExtension on MatchLevel {
  String get label {
    switch (this) {
      case MatchLevel.excellent:
        return 'Excellent';
      case MatchLevel.good:
        return 'Good';
      case MatchLevel.fair:
        return 'Fair';
      case MatchLevel.poor:
        return 'Poor';
    }
  }

  Color get color {
    switch (this) {
      case MatchLevel.excellent:
        return AppColors.success;
      case MatchLevel.good:
        return Colors.blue;
      case MatchLevel.fair:
        return AppColors.warning;
      case MatchLevel.poor:
        return AppColors.error;
    }
  }

  String get description {
    switch (this) {
      case MatchLevel.excellent:
        return 'Perfect match! You have almost all the required skills.';
      case MatchLevel.good:
        return 'Great match! You meet most requirements.';
      case MatchLevel.fair:
        return 'Decent match. Consider learning missing skills.';
      case MatchLevel.poor:
        return 'Low match. Many skills need to be acquired.';
    }
  }
}

/// Simple Match Badge
/// 
/// Compact match percentage indicator
class MatchBadge extends StatelessWidget {
  final int percentage;
  final double size;

  const MatchBadge({
    super.key,
    required this.percentage,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final matchLevel = _getMatchLevel(percentage);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: matchLevel.color.withAlpha((255 * 0.1).toInt()),
        shape: BoxShape.circle,
        border: Border.all(
          color: matchLevel.color,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$percentage%',
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: matchLevel.color,
          ),
        ),
      ),
    );
  }

  MatchLevel _getMatchLevel(int percentage) {
    if (percentage >= 80) return MatchLevel.excellent;
    if (percentage >= 60) return MatchLevel.good;
    if (percentage >= 40) return MatchLevel.fair;
    return MatchLevel.poor;
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final bool isMatched;

  const _SkillChip({
    required this.label,
    required this.isMatched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: isMatched
            ? AppColors.success.withAlpha((255 * 0.1).toInt())
            : AppColors.warning.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isMatched ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isMatched ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}
