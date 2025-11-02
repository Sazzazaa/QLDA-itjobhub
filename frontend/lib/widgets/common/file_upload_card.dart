import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// File Upload Card
/// 
/// A card for uploading files (CV, documents, images)
/// 
/// Example:
/// ```dart
/// FileUploadCard(
///   title: 'Upload your CV',
///   onUpload: () => _pickFile(),
///   acceptedFormats: ['PDF', 'DOC', 'DOCX'],
/// )
/// ```
class FileUploadCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onUpload;
  final String? fileName;
  final double? uploadProgress; // 0.0 to 1.0
  final VoidCallback? onRemove;
  final List<String>? acceptedFormats;
  final String? maxSize;
  final IconData? icon;
  final bool isUploading;

  const FileUploadCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.onUpload,
    this.fileName,
    this.uploadProgress,
    this.onRemove,
    this.acceptedFormats,
    this.maxSize,
    this.icon,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return Card(
      child: InkWell(
        onTap: hasFile && !isUploading ? null : onUpload,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: hasFile
                          ? AppColors.success.withAlpha((255 * 0.1).toInt())
                          : AppColors.primary.withAlpha((255 * 0.1).toInt()),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      icon ?? (hasFile ? Icons.check_circle : Icons.upload_file),
                      color: hasFile ? AppColors.success : AppColors.primary,
                      size: AppSizes.iconL,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasFile && onRemove != null && !isUploading)
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                      tooltip: 'Remove file',
                    ),
                ],
              ),

              // File name or instructions
              if (hasFile) ...[
                const SizedBox(height: AppSizes.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: AppSizes.iconM,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: Text(
                          fileName!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Upload progress
              if (isUploading && uploadProgress != null) ...[
                const SizedBox(height: AppSizes.spacingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Uploading...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(uploadProgress! * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: uploadProgress,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],

              // Format and size info
              if (!hasFile && (acceptedFormats != null || maxSize != null)) ...[
                const SizedBox(height: AppSizes.spacingM),
                const Divider(),
                const SizedBox(height: AppSizes.spacingM),
                Row(
                  children: [
                    if (acceptedFormats != null) ...[
                      const Icon(
                        Icons.info_outline,
                        size: AppSizes.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: Text(
                          'Accepted formats: ${acceptedFormats!.join(', ')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (maxSize != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: AppSizes.iconS + AppSizes.spacingS),
                      Text(
                        'Max size: $maxSize',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple Upload Button
/// 
/// A compact button for file uploads
class UploadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData icon;

  const UploadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon = Icons.cloud_upload,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: AppSizes.iconS),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
      ),
    );
  }
}
