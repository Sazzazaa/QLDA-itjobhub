import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';

/// Portfolio Link Card
/// 
/// Displays an external portfolio link (GitHub, Behance, etc.)
/// 
/// Example:
/// ```dart
/// PortfolioLinkCard(
///   platform: PortfolioPlatform.github,
///   url: 'https://github.com/username',
///   username: 'username',
/// )
/// ```
class PortfolioLinkCard extends StatelessWidget {
  final PortfolioPlatform platform;
  final String url;
  final String? username;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PortfolioLinkCard({
    super.key,
    required this.platform,
    required this.url,
    this.username,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              // Platform icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: platform.color.withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  platform.icon,
                  color: platform.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),

              // Platform name and URL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      username ?? _extractUsername(url),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Actions
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.error,
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              const Icon(
                Icons.open_in_new,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractUsername(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      return segments.isNotEmpty ? segments.first : url;
    } catch (e) {
      return url;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Portfolio Platform
enum PortfolioPlatform {
  github,
  linkedin,
  behance,
  dribbble,
  website,
  gitlab,
  stackoverflow,
  medium,
}

extension PortfolioPlatformExtension on PortfolioPlatform {
  String get name {
    switch (this) {
      case PortfolioPlatform.github:
        return 'GitHub';
      case PortfolioPlatform.linkedin:
        return 'LinkedIn';
      case PortfolioPlatform.behance:
        return 'Behance';
      case PortfolioPlatform.dribbble:
        return 'Dribbble';
      case PortfolioPlatform.website:
        return 'Website';
      case PortfolioPlatform.gitlab:
        return 'GitLab';
      case PortfolioPlatform.stackoverflow:
        return 'Stack Overflow';
      case PortfolioPlatform.medium:
        return 'Medium';
    }
  }

  IconData get icon {
    switch (this) {
      case PortfolioPlatform.github:
      case PortfolioPlatform.gitlab:
        return Icons.code;
      case PortfolioPlatform.linkedin:
        return Icons.business;
      case PortfolioPlatform.behance:
      case PortfolioPlatform.dribbble:
        return Icons.palette;
      case PortfolioPlatform.website:
        return Icons.language;
      case PortfolioPlatform.stackoverflow:
        return Icons.question_answer;
      case PortfolioPlatform.medium:
        return Icons.article;
    }
  }

  Color get color {
    switch (this) {
      case PortfolioPlatform.github:
        return const Color(0xFF333333);
      case PortfolioPlatform.linkedin:
        return const Color(0xFF0077B5);
      case PortfolioPlatform.behance:
        return const Color(0xFF1769FF);
      case PortfolioPlatform.dribbble:
        return const Color(0xFFEA4C89);
      case PortfolioPlatform.website:
        return AppColors.primary;
      case PortfolioPlatform.gitlab:
        return const Color(0xFFFCA121);
      case PortfolioPlatform.stackoverflow:
        return const Color(0xFFF48024);
      case PortfolioPlatform.medium:
        return const Color(0xFF000000);
    }
  }
}

/// Simple Link Button
class LinkButton extends StatelessWidget {
  final String label;
  final String url;
  final IconData? icon;

  const LinkButton({
    super.key,
    required this.label,
    required this.url,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _launchURL(url),
      icon: Icon(icon ?? Icons.link, size: 18),
      label: Text(label),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
