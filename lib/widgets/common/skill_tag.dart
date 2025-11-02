import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Skill Tag
/// 
/// A chip-style widget for displaying skills with optional remove button
/// 
/// Example:
/// ```dart
/// SkillTag(
///   label: 'Flutter',
///   onDelete: () => _removeSkill('Flutter'),
/// )
/// 
/// SkillTag(
///   label: 'React Native',
///   level: SkillLevel.expert,
/// )
/// ```
class SkillTag extends StatelessWidget {
  final String label;
  final SkillLevel? level;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? textColor;

  const SkillTag({
    super.key,
    required this.label,
    this.level,
    this.onDelete,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isSelected
        ? AppColors.primary
        : backgroundColor ?? AppColors.primaryLight.withAlpha((255 * 0.15).toInt());

    final effectiveTextColor = isSelected
        ? Colors.white
        : textColor ?? AppColors.primary;

    final levelColor = level?.color ?? Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: level != null
                ? Border.all(color: levelColor, width: 2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skill level indicator dot
              if (level != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: levelColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
              ],

              // Label
              Text(
                label,
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Delete button
              if (onDelete != null) ...[
                const SizedBox(width: AppSizes.spacingS),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    size: AppSizes.iconXS,
                    color: effectiveTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Skill Level Indicator
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension SkillLevelExtension on SkillLevel {
  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case SkillLevel.beginner:
        return Colors.grey;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.orange;
      case SkillLevel.expert:
        return Colors.green;
    }
  }
}

/// Skill Tag with Level Badge
/// 
/// Shows skill with a level badge on top-right
class SkillTagWithBadge extends StatelessWidget {
  final String label;
  final SkillLevel level;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SkillTagWithBadge({
    super.key,
    required this.label,
    required this.level,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SkillTag(
          label: label,
          level: level,
          onDelete: onDelete,
          onTap: onTap,
        ),
        if (level != SkillLevel.beginner)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: level.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                level.displayName[0], // First letter
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
