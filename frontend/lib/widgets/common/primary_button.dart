import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';

/// Primary button widget with consistent styling across the app
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: _getIconSize()),
                  const SizedBox(width: AppSizes.spacingS),
                  Text(label),
                ],
              )
            : Text(label);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        elevation: AppElevations.button,
        minimumSize: size == ButtonSize.small ? const Size(0, 0) : null,
      ),
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.paddingM;
      case ButtonSize.medium:
        return AppSizes.paddingL;
      case ButtonSize.large:
        return AppSizes.paddingXL;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.paddingS;
      case ButtonSize.medium:
        return AppSizes.paddingM;
      case ButtonSize.large:
        return AppSizes.paddingL;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

/// Secondary button with outline style
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: _getIconSize()),
                  const SizedBox(width: AppSizes.spacingS),
                  Text(label),
                ],
              )
            : Text(label);

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        minimumSize: size == ButtonSize.small ? const Size(0, 0) : null,
      ),
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.paddingM;
      case ButtonSize.medium:
        return AppSizes.paddingL;
      case ButtonSize.large:
        return AppSizes.paddingXL;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.paddingS;
      case ButtonSize.medium:
        return AppSizes.paddingM;
      case ButtonSize.large:
        return AppSizes.paddingL;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

/// Text button with minimal style (avoid conflict with Flutter's TextButton)
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonSize size;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: _getIconSize(), color: AppColors.primary),
                const SizedBox(width: AppSizes.spacingS),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            )
          : Text(
              label,
              style: const TextStyle(color: AppColors.primary),
            ),
    );
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.paddingM;
      case ButtonSize.medium:
        return AppSizes.paddingL;
      case ButtonSize.large:
        return AppSizes.paddingXL;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.paddingS;
      case ButtonSize.medium:
        return AppSizes.paddingM;
      case ButtonSize.large:
        return AppSizes.paddingL;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

enum ButtonSize {
  small,
  medium,
  large,
}
