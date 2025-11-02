import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_application_model.dart';
import 'package:itjobhub/features/candidate/screens/interview_scheduling_screen.dart';
import 'package:itjobhub/services/interview_service.dart';
import 'package:itjobhub/models/interview_model.dart';
import 'package:itjobhub/services/message_service.dart';
import 'package:itjobhub/services/application_service.dart';
import 'package:itjobhub/features/shared/screens/chat_screen.dart';
import 'package:itjobhub/features/employer/screens/write_candidate_review_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final JobApplication application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final InterviewService _interviewService = InterviewService();
  final MessageService _messageService = MessageService();
  final ApplicationService _applicationService = ApplicationService();
  List<Interview>? _scheduledInterviews;
  late ApplicationStatus _currentStatus;
  bool _isUpdating = false;
  bool _isCompleting = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application.status;
    _loadInterviews();
  }

  void _loadInterviews() {
    // Get interviews for this application
    final allInterviews = _interviewService.getAllInterviews();
    setState(() {
      // Only show interviews that are tied to this specific application (avoid showing other
      // interviews for the same job). This prevents scheduling/mark-as-completed confusion.
      _scheduledInterviews = allInterviews
          .where((i) => i.applicationId == widget.application.id)
          .toList();
    });
  }

  Future<void> _scheduleInterview() async {
    // Cannot schedule interview if application is rejected
    if (_currentStatus == ApplicationStatus.rejected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot schedule interview for rejected application'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterviewSchedulingScreen(
          jobId: widget.application.job.id,
          jobTitle: widget.application.job.title,
          companyName: widget.application.job.companyName,
          candidateId: widget.application.candidate.id,
          applicationId: widget.application.id,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadInterviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interview scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    try {
      // Get or create conversation with the candidate
      final conversation = await _messageService.getOrCreateConversation(
        participantId: widget.application.candidate.id,
        participantName: widget.application.candidate.name,
        participantRole: 'candidate',
        jobId: widget.application.job.id,
        jobTitle: widget.application.job.title,
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

  Future<void> _updateStatus(ApplicationStatus newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _applicationService.updateApplicationStatus(
        applicationId: widget.application.id,
        status: newStatus.name,
        note: 'Status updated to ${newStatus.displayName}',
      );

      setState(() {
        _currentStatus = newStatus;
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application ${newStatus.displayName.toLowerCase()}'),
            backgroundColor: Colors.green,
          ),
        );
        // Don't pop - stay on screen to allow scheduling interview or further actions
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markInterviewCompleted(String interviewId) async {
    setState(() => _isCompleting = true);
    try {
      await _interviewService.completeInterview(interviewId);

      // Reload interviews to update UI
      _loadInterviews();

      // Also update the application status locally by calling the application service
      try {
        await _applicationService.updateApplicationStatus(
          applicationId: widget.application.id,
          status: 'interview_completed',
          note: 'Interview completed',
        );
        setState(() => _currentStatus = ApplicationStatus.interviewCompleted);
      } catch (appErr) {
        // Non-fatal - show a message but proceed
        print('Warning: failed to refresh application status after interview completion: $appErr');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview marked as completed! You can now make final hiring decision.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete interview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.application.candidate.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.application.candidate.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.application.candidate.currentPosition ?? 'Candidate',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Contact info
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(Icons.email, widget.application.candidate.email),
                    const Divider(),
                    _InfoRow(Icons.phone, widget.application.candidate.phone),
                    const Divider(),
                    _InfoRow(Icons.location_on, widget.application.candidate.location),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Scheduled Interviews Section
            if (_scheduledInterviews != null && _scheduledInterviews!.isNotEmpty) ...[
              Text(
                'Scheduled Interviews',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._scheduledInterviews!.map((interview) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      interview.type == InterviewType.online
                          ? Icons.videocam
                          : Icons.location_on,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    interview.type.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${interview.formattedDate} at ${interview.formattedTime}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Confirmed badge
                      if (interview.confirmed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Confirmed',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          interview.status.displayName,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: interview.status == InterviewStatus.scheduled
                            ? Colors.blue.shade50
                            : interview.status == InterviewStatus.completed
                                ? Colors.green.shade50
                                : Colors.grey.shade200,
                      ),
                      if (interview.status == InterviewStatus.scheduled) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          tooltip: 'Mark as Completed',
                          onPressed: _isCompleting ? null : () => _markInterviewCompleted(interview.id),
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ],
            
            // Hire/Reject Buttons (show if candidate confirmed interview)
            if (_scheduledInterviews != null && 
                _scheduledInterviews!.any((i) => i.confirmed && i.status == InterviewStatus.scheduled)) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Candidate has confirmed the interview',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _hireCandidate,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Hire'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isProcessing ? null : _rejectCandidate,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.message),
                    label: const Text('Send Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                // Only show Schedule Interview button if not approved yet
                if (_currentStatus != ApplicationStatus.approved) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                        onPressed: (_currentStatus == ApplicationStatus.rejected ||
                                  (_scheduledInterviews != null && _scheduledInterviews!.any((i) => i.status == InterviewStatus.scheduled || i.status == InterviewStatus.rescheduled)))
                          ? null
                          : _scheduleInterview,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule Interview'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Write Review Button (only if interview was completed)
            if (_scheduledInterviews != null && _scheduledInterviews!.any((i) => i.status == InterviewStatus.completed)) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WriteCandidateReviewScreen(
                          candidateId: widget.application.candidate.id,
                          candidateName: widget.application.candidate.name,
                          jobTitle: widget.application.job.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Write Review for Candidate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Actions
            if (_currentStatus == ApplicationStatus.pending) ...[
              // Show three buttons: Reviewing, Reject, Approve
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.reviewing),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Mark as Reviewing'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.rejected),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.approved),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (_currentStatus == ApplicationStatus.reviewing) ...[
              // Show reviewing status with approve/reject options
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Under Review',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.rejected),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.approved),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (_currentStatus == ApplicationStatus.rejected) ...[
              // Show rejected status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Application Rejected',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_currentStatus == ApplicationStatus.approved) ...[
              // Show approved status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Application Approved - Schedule Interview',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_currentStatus == ApplicationStatus.interviewScheduled) ...[
              // Show interview in progress status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Interview Scheduled',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_currentStatus == ApplicationStatus.interviewCompleted) ...[
              // Show hire/reject final decision
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in, color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Interview Completed - Make Final Decision',
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.rejected),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateStatus(ApplicationStatus.hired),
                          icon: const Icon(Icons.work),
                          label: const Text('Hire'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (_currentStatus == ApplicationStatus.hired) ...[
              // Show hired status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Candidate Hired! 🎉',
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _hireCandidate() async {
    setState(() => _isProcessing = true);
    try {
      // Update status to approved (hired)
      await _updateStatus(ApplicationStatus.approved);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Candidate hired successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectCandidate() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Candidate'),
        content: const Text(
          'Are you sure you want to reject this candidate? This will delete the application permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      // Delete the application
      await _applicationService.deleteApplication(widget.application.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted'),
            backgroundColor: Colors.orange,
          ),
        );
        // Go back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete application: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
