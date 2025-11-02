import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onTap;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha((255 * 0.1).toInt()),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  // Title and Company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.spacingXS),
                        Text(
                          application.job.companyName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: application.status.color.withAlpha((255 * 0.1).toInt()),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      border: Border.all(
                        color: application.status.color.withAlpha((255 * 0.3).toInt()),
                      ),
                    ),
                    child: Text(
                      application.statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: application.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Job Info
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: application.job.location,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  _InfoChip(
                    icon: Icons.attach_money,
                    label: application.job.salaryRange,
                  ),
                ],
              ),
              
              // Notes (if any)
              if (application.notes != null) ...[
                const SizedBox(height: AppSizes.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: application.status == ApplicationStatus.approved
                        ? AppColors.success.withAlpha((255 * 0.05).toInt())
                        : AppColors.textSecondary.withAlpha((255 * 0.05).toInt()),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        application.status == ApplicationStatus.approved
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        size: 20,
                        color: application.status == ApplicationStatus.approved
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: Text(
                          application.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppSizes.spacingM),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.spacingM),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    application.appliedTimeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (application.lastUpdateDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.update,
                          size: 14,
                          color: AppColors.textSecondary.withAlpha((255 * 0.7).toInt()),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          application.lastUpdateText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
