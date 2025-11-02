import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/widgets/common/index.dart';
import 'package:itjobhub/features/candidate/screens/job_application_form_screen.dart';
import 'package:itjobhub/features/shared/screens/company_reviews_screen.dart';
import 'package:itjobhub/services/application_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isBookmarked = false;
  bool _hasApplied = false;
  bool _isApplying = false;
  bool _isCheckingApplication = true;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.job.isBookmarked;
    _hasApplied = widget.job.hasApplied;
    _checkIfAlreadyApplied();
  }

  Future<void> _checkIfAlreadyApplied() async {
    try {
      // Fetch all user applications
      final applications = await ApplicationService().fetchApplications();
      
      // Check if any application matches this job
      final hasApplied = applications.any((app) => app.job.id == widget.job.id);
      
      if (mounted) {
        setState(() {
          _hasApplied = hasApplied;
          _isCheckingApplication = false;
        });
      }
    } catch (e) {
      print('Error checking application status: $e');
      if (mounted) {
        setState(() => _isCheckingApplication = false);
      }
    }
  }

  Future<void> _applyForJob() async {
    // Navigate to application form
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationFormScreen(job: widget.job),
      ),
    );

    // If application was submitted successfully
    if (result == true && mounted) {
      setState(() {
        _hasApplied = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Added to bookmarks'
                        : 'Removed from bookmarks',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo and Name
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withAlpha(
                            (255 * 0.1).toInt(),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: const Icon(
                          Icons.business,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job.companyName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              widget.job.location,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingL),

                  // Job Title
                  Text(
                    widget.job.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),

                  // Job Info Chips
                  Wrap(
                    spacing: AppSizes.spacingM,
                    runSpacing: AppSizes.spacingM,
                    children: [
                      _InfoChip(
                        icon: Icons.work_outline,
                        label: widget.job.jobType.displayName,
                      ),
                      _InfoChip(
                        icon: Icons.school_outlined,
                        label: widget.job.experienceLevel.displayName,
                      ),
                      _InfoChip(
                        icon: Icons.attach_money,
                        label: widget.job.salaryRange,
                        color: AppColors.success,
                      ),
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: '${widget.job.applicantCount} applicants',
                      ),
                      _InfoChip(
                        icon: Icons.access_time,
                        label: widget.job.timeAgo,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingXL),

                  // Tech Stack
                  _Section(
                    title: 'Tech Stack',
                    child: Wrap(
                      spacing: AppSizes.spacingS,
                      runSpacing: AppSizes.spacingS,
                      children: widget.job.techStack.map((tech) {
                        return StatusChip(
                          label: tech,
                          color: AppColors.primary,
                          size: ChipSize.small,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXL),

                  // Job Description
                  _Section(
                    title: 'Job Description',
                    child: Text(
                      widget.job.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXL),

                  // Requirements
                  _Section(
                    title: 'Requirements',
                    child: Text(
                      widget.job.requirements,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  if (widget.job.benefits != null) ...[
                    const SizedBox(height: AppSizes.spacingXL),
                    _Section(
                      title: 'Benefits',
                      child: Text(
                        widget.job.benefits!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingXL * 2),
                  // Company Reviews Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompanyReviewsScreen(
                              companyId: 'comp_${widget.job.id}',
                              companyName: widget.job.companyName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text('See Company Reviews'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.05).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _isCheckingApplication
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingM),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _hasApplied
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha((255 * 0.1).toInt()),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSizes.spacingS),
                          Text(
                            'Application Submitted',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    )
                  : PrimaryButton(
                      label: 'Apply Now',
                      onPressed: _applyForJob,
                      isLoading: _isApplying,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.spacingM),
        child,
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withAlpha(
          (255 * 0.1).toInt(),
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
