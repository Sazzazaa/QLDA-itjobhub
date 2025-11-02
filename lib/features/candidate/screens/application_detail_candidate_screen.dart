import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/application_model.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/services/interview_service.dart';
import 'package:itjobhub/services/application_service.dart';
import 'package:itjobhub/models/interview_model.dart';
import 'package:itjobhub/features/candidate/screens/interview_detail_screen.dart';
import 'package:itjobhub/features/candidate/screens/job_detail_screen.dart';
import 'package:itjobhub/services/message_service.dart';
import 'package:itjobhub/features/shared/screens/chat_screen.dart';

/// Application Detail Screen for Candidates
/// 
/// Shows detailed application status, timeline, and employer feedback
class ApplicationDetailCandidateScreen extends StatefulWidget {
  final Application application;
  
  const ApplicationDetailCandidateScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailCandidateScreen> createState() => _ApplicationDetailCandidateScreenState();
}

class _ApplicationDetailCandidateScreenState extends State<ApplicationDetailCandidateScreen> {
  final InterviewService _interviewService = InterviewService();
  final MessageService _messageService = MessageService();
  final ApplicationService _applicationService = ApplicationService();
  late Application _application;
  bool _isWithdrawing = false;
  bool _isRefreshing = false;
  List<Interview> _scheduledInterviews = [];

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    _loadInterviews();
  }

  void _loadInterviews() {
    final allInterviews = _interviewService.getAllInterviews();
    setState(() {
      _scheduledInterviews = allInterviews
          .where((i) => i.jobId == _application.job.id)
          .where((i) => i.scheduledAt.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    });
  }

  Future<void> _refreshApplication() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final applications = await _applicationService.fetchApplications();
      final updatedApp = applications.firstWhere(
        (app) => app.id == _application.id,
        orElse: () => _application,
      );

      setState(() {
        _application = updatedApp;
        _isRefreshing = false;
      });

      _loadInterviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application status refreshed'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _withdrawApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: const Text(
          'Are you sure you want to withdraw your application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isWithdrawing = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isWithdrawing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application withdrawn successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return with success flag
      }
    }
  }

  Future<void> _sendMessage() async {
    // Check if employerId is available
    if (_application.employerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employer information not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Get or create conversation with the employer
      final conversation = await _messageService.getOrCreateConversation(
        participantId: _application.employerId!,
        participantName: _application.job.companyName,
        participantRole: 'employer',
        jobId: _application.job.id,
        jobTitle: _application.job.title,
      );

      if (mounted) {
        // Navigate to chat screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canWithdraw = _application.status == ApplicationStatus.pending ||
        _application.status == ApplicationStatus.reviewing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          IconButton(
            icon: _isRefreshing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: _isRefreshing ? null : _refreshApplication,
          ),
          if (canWithdraw && !_isWithdrawing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Withdraw Application',
              onPressed: _withdrawApplication,
            ),
          if (_isWithdrawing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: _application.status.color.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(_application.status),
                    size: 64,
                    color: _application.status.color,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    _application.status.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _application.status.color,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    _application.appliedTimeAgo,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  size: 28,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _application.job.title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _application.job.companyName,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _application.job.location,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          const Divider(),
                          const SizedBox(height: AppSizes.spacingM),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: Text(_application.job.jobType.displayName),
                                avatar: const Icon(Icons.work_outline, size: 16),
                              ),
                              Chip(
                                label: Text(_application.job.experienceLevel.displayName),
                                avatar: const Icon(Icons.school_outlined, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXL),

                  // Scheduled Interviews Section
                  if (_scheduledInterviews.isNotEmpty) ...[
                    Text(
                      'Upcoming Interviews',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    ..._scheduledInterviews.map((interview) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InterviewDetailScreen(
                                interview: interview,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getInterviewTypeColor(interview.type).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                ),
                                child: Icon(
                                  _getInterviewTypeIcon(interview.type),
                                  color: _getInterviewTypeColor(interview.type),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      interview.type.displayName,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${interview.formattedDate} • ${interview.formattedTime}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (interview.isWithin24Hours) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 14,
                                            color: Colors.orange.shade700,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Starting soon!',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: AppSizes.spacingXL),
                  ],

                  // Application Timeline
                  Text(
                    'Application Timeline',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  _buildTimeline(context),
                  const SizedBox(height: AppSizes.spacingXL),

                  // Employer Notes/Feedback
                  if (_application.notes != null) ...[
                    Text(
                      'Message from Employer',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.message_outlined,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _application.lastUpdateText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          Text(
                            _application.notes!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXL),
                  ],

                  // Actions
                  if (_application.status == ApplicationStatus.approved) ...[
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeightL,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Schedule interview coming soon')),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Schedule Interview'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSizes.buttonHeightM,
                          child: OutlinedButton.icon(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.message),
                            label: const Text('Message Employer'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: SizedBox(
                          height: AppSizes.buttonHeightM,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navigate to job detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailScreen(job: _application.job),
                                ),
                              );
                            },
                            icon: const Icon(Icons.work_outline),
                            label: const Text('Job Details'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final steps = _getTimelineSteps();
    
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        
        return _TimelineItem(
          icon: step.icon,
          title: step.title,
          subtitle: step.subtitle,
          isCompleted: step.isCompleted,
          isActive: step.isActive,
          isLast: isLast,
        );
      }),
    );
  }

  List<_TimelineStep> _getTimelineSteps() {
    final status = _application.status;
    
    return [
      _TimelineStep(
        icon: Icons.send,
        title: 'Application Submitted',
        subtitle: _formatDate(_application.appliedDate),
        isCompleted: true,
        isActive: false,
      ),
      _TimelineStep(
        icon: Icons.visibility,
        title: 'Under Review',
        subtitle: status.index >= ApplicationStatus.reviewing.index
            ? _formatDate(_application.lastUpdateDate ?? _application.appliedDate)
            : 'Pending',
        isCompleted: status.index >= ApplicationStatus.reviewing.index,
        isActive: status == ApplicationStatus.reviewing,
      ),
      if (status == ApplicationStatus.interview || status == ApplicationStatus.approved) ...[
        _TimelineStep(
          icon: Icons.calendar_month,
          title: 'Interview Scheduled',
          subtitle: status == ApplicationStatus.interview
              ? _formatDate(_application.lastUpdateDate ?? DateTime.now())
              : _formatDate(_application.lastUpdateDate ?? DateTime.now()),
          isCompleted: status.index >= ApplicationStatus.interview.index,
          isActive: status == ApplicationStatus.interview,
        ),
      ],
      _TimelineStep(
        icon: status == ApplicationStatus.rejected
            ? Icons.cancel
            : Icons.check_circle,
        title: status == ApplicationStatus.rejected
            ? 'Application Rejected'
            : 'Offer Extended',
        subtitle: status == ApplicationStatus.approved || status == ApplicationStatus.rejected
            ? _formatDate(_application.lastUpdateDate ?? DateTime.now())
            : 'Waiting for decision',
        isCompleted: status == ApplicationStatus.approved || status == ApplicationStatus.rejected,
        isActive: false,
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getInterviewTypeColor(InterviewType type) {
    switch (type) {
      case InterviewType.online:
        return Colors.purple;
      case InterviewType.onsite:
        return Colors.green;
    }
  }

  IconData _getInterviewTypeIcon(InterviewType type) {
    switch (type) {
      case InterviewType.online:
        return Icons.videocam;
      case InterviewType.onsite:
        return Icons.location_on;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.schedule;
      case ApplicationStatus.reviewing:
        return Icons.visibility;
      case ApplicationStatus.interview:
      case ApplicationStatus.interviewScheduled:
      case ApplicationStatus.interviewCompleted:
        return Icons.calendar_month;
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.hired:
        return Icons.celebration;
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return Icons.cancel;
    }
  }
}

class _TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textHint;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted ? AppColors.success : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.spacingM),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted || isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
