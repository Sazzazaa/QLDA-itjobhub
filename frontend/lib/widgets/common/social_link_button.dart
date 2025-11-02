import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable widget for displaying social media links (GitHub, LinkedIn, etc.)
class SocialLinkButton extends StatelessWidget {
  final String url;
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialLinkButton({
    super.key,
    required this.url,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  /// Factory constructor for GitHub link
  factory SocialLinkButton.github({
    required String url,
  }) {
    return SocialLinkButton(
      url: url,
      label: 'GitHub',
      icon: Icons.code,
      backgroundColor: Colors.white,
      textColor: Colors.grey.shade800,
      borderColor: Colors.grey.shade300,
    );
  }

  /// Factory constructor for LinkedIn link
  factory SocialLinkButton.linkedin({
    required String url,
  }) {
    return SocialLinkButton(
      url: url,
      label: 'LinkedIn',
      icon: Icons.work_outline,
      backgroundColor: const Color(0xFF0A66C2),
      textColor: Colors.white,
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchUrl(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor ?? Colors.grey.shade800,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display multiple social links in a row
class SocialLinksRow extends StatelessWidget {
  final String? githubUrl;
  final String? linkedinUrl;
  final MainAxisAlignment alignment;

  const SocialLinksRow({
    super.key,
    this.githubUrl,
    this.linkedinUrl,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty container if no links are provided
    if (githubUrl == null && linkedinUrl == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (githubUrl != null)
          SocialLinkButton.github(url: githubUrl!),
        if (githubUrl != null && linkedinUrl != null)
          const SizedBox(width: 12),
        if (linkedinUrl != null)
          SocialLinkButton.linkedin(url: linkedinUrl!),
      ],
    );
  }
}
