import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Social Login Button
/// 
/// A reusable button for social authentication (Google, GitHub, LinkedIn)
/// 
/// Example:
/// ```dart
/// SocialLoginButton(
///   provider: SocialProvider.google,
///   onPressed: () => _handleGoogleLogin(),
/// )
/// ```
class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSizes.buttonHeightM,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.divider,
            width: 1.5,
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: AppSizes.iconS,
                width: AppSizes.iconS,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    provider.color,
                  ),
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    provider.icon,
                    size: AppSizes.iconS,
                    color: provider.color,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Text(
                    provider.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Social Authentication Providers
enum SocialProvider {
  google,
  github,
  linkedin,
}

extension SocialProviderExtension on SocialProvider {
  String get label {
    switch (this) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.github:
        return 'Continue with GitHub';
      case SocialProvider.linkedin:
        return 'Continue with LinkedIn';
    }
  }

  IconData get icon {
    switch (this) {
      case SocialProvider.google:
        return Icons.g_mobiledata_rounded; // Google icon
      case SocialProvider.github:
        return Icons.code; // GitHub icon (use font_awesome for better icon)
      case SocialProvider.linkedin:
        return Icons.business; // LinkedIn icon (use font_awesome for better icon)
    }
  }

  Color get color {
    switch (this) {
      case SocialProvider.google:
        return const Color(0xFFDB4437); // Google Red
      case SocialProvider.github:
        return const Color(0xFF333333); // GitHub Black
      case SocialProvider.linkedin:
        return const Color(0xFF0077B5); // LinkedIn Blue
    }
  }
}
