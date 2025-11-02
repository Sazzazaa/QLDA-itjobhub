import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';

/// Status chip widget for displaying status with consistent styling
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final ChipSize size;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.size = ChipSize.medium,
  });

  /// Factory for application status chips
  factory StatusChip.applicationStatus(ApplicationStatus status, {ChipSize size = ChipSize.medium}) {
    return StatusChip(
      label: status.displayName,
      color: status.color,
      icon: _getStatusIcon(status),
      size: size,
    );
  }

  /// Factory for job type chips
  factory StatusChip.jobType(String type, {ChipSize size = ChipSize.medium}) {
    return StatusChip(
      label: type,
      color: AppColors.info,
      icon: Icons.work_outline,
      size: size,
    );
  }

  /// Factory for experience level chips
  factory StatusChip.experienceLevel(String level, {ChipSize size = ChipSize.medium}) {
    return StatusChip(
      label: level,
      color: AppColors.primary,
      icon: Icons.trending_up,
      size: size,
    );
  }

  static IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.schedule;
      case ApplicationStatus.reviewing:
        return Icons.rate_review;
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.interview:
      case ApplicationStatus.interviewScheduled:
      case ApplicationStatus.interviewCompleted:
        return Icons.event;
      case ApplicationStatus.hired:
        return Icons.celebration;
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: color,
            ),
            SizedBox(width: _getIconSpacing()),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ChipSize.small:
        return AppSizes.paddingS;
      case ChipSize.medium:
        return AppSizes.paddingM;
      case ChipSize.large:
        return AppSizes.paddingL;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ChipSize.small:
        return AppSizes.paddingXS;
      case ChipSize.medium:
        return AppSizes.paddingS;
      case ChipSize.large:
        return AppSizes.paddingM;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ChipSize.small:
        return AppSizes.radiusS;
      case ChipSize.medium:
        return AppSizes.radiusM;
      case ChipSize.large:
        return AppSizes.radiusL;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ChipSize.small:
        return 14;
      case ChipSize.medium:
        return 16;
      case ChipSize.large:
        return 18;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case ChipSize.small:
        return 4;
      case ChipSize.medium:
        return 6;
      case ChipSize.large:
        return 8;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ChipSize.small:
        return 12;
      case ChipSize.medium:
        return 14;
      case ChipSize.large:
        return 16;
    }
  }
}

/// Selectable chip for filters
class SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ChipSize size;

  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.size = ChipSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: _getFontSize(),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ChipSize.small:
        return AppSizes.paddingS;
      case ChipSize.medium:
        return AppSizes.paddingM;
      case ChipSize.large:
        return AppSizes.paddingL;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ChipSize.small:
        return AppSizes.paddingXS;
      case ChipSize.medium:
        return AppSizes.paddingS;
      case ChipSize.large:
        return AppSizes.paddingM;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ChipSize.small:
        return AppSizes.radiusS;
      case ChipSize.medium:
        return AppSizes.radiusM;
      case ChipSize.large:
        return AppSizes.radiusL;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ChipSize.small:
        return 12;
      case ChipSize.medium:
        return 14;
      case ChipSize.large:
        return 16;
    }
  }
}

enum ChipSize {
  small,
  medium,
  large,
}
