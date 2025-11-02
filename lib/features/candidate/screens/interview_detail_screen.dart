import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/interview_model.dart';
import 'package:itjobhub/services/interview_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itjobhub/features/shared/screens/write_company_review_screen.dart';

/// Interview Detail Screen
/// Shows detailed information about a specific interview
class InterviewDetailScreen extends StatefulWidget {
  final Interview interview;

  const InterviewDetailScreen({super.key, required this.interview});

  @override
  State<InterviewDetailScreen> createState() => _InterviewDetailScreenState();
}

class _InterviewDetailScreenState extends State<InterviewDetailScreen> {
  final InterviewService _interviewService = InterviewService();
  late Interview _interview;

  @override
  void initState() {
    super.initState();
    _interview = widget.interview;
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming =
        _interview.status == InterviewStatus.scheduled &&
        _interview.scheduledAt.isAfter(DateTime.now());
    final canConfirm = isUpcoming && !_interview.confirmed;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Interview Details'),
        elevation: 0,
        backgroundColor: Colors.blue,
        actions: [
          if (isUpcoming)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'reschedule':
                    _showRescheduleDialog();
                    break;
                  case 'cancel':
                    _showCancelDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reschedule',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 20),
                      SizedBox(width: 12),
                      Text('Reschedule'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Cancel Interview',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Company Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _interview.companyLogo,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Title
                  Text(
                    _interview.jobTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Company Name
                  Text(
                    _interview.companyName,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Urgent Alert - show if interview is within 24 hours
            if (isUpcoming && _interview.isWithin24Hours) _buildUrgentAlert(),

            // Interview Details
            _buildSectionCard(
              title: 'Interview Details',
              icon: Icons.info_outline,
              children: [
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: _interview.formattedDate,
                  color: AppColors.primary,
                ),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: _interview.formattedTime,
                  color: Colors.orange,
                ),
                _buildDetailRow(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: '${_interview.durationMinutes} minutes',
                  color: Colors.purple,
                ),
                _buildDetailRow(
                  icon: Icons.video_call,
                  label: 'Type',
                  value: _interview.type.displayName,
                  color: Colors.green,
                ),
              ],
            ),

            // Meeting Information
            if (_interview.type == InterviewType.online &&
                _interview.meetingLink != null)
              _buildSectionCard(
                title: 'Meeting Link',
                icon: Icons.link,
                children: [
                  InkWell(
                    onTap: () => _openLink(_interview.meetingLink!),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.videocam,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _interview.meetingLink!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () =>
                                _copyToClipboard(_interview.meetingLink!),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Location
            if (_interview.type == InterviewType.onsite &&
                _interview.location != null)
              _buildSectionCard(
                title: 'Location',
                icon: Icons.location_on,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _interview.location!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            // Interviewer
            _buildSectionCard(
              title: 'Interviewer',
              icon: Icons.person,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      _interview.interviewerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    _interview.interviewerName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_interview.interviewerTitle != null)
                        Text(_interview.interviewerTitle!),
                      if (_interview.interviewerEmail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _interview.interviewerEmail!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Notes
            if (_interview.notes != null)
              _buildSectionCard(
                title: 'Notes',
                icon: Icons.note,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _interview.notes!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),

            // Documents
            if (_interview.documents != null &&
                _interview.documents!.isNotEmpty)
              _buildSectionCard(
                title: 'Required Documents',
                icon: Icons.description,
                children: [
                  ..._interview.documents!.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(doc, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Feedback (for completed interviews)
            if (_interview.feedback != null)
              _buildSectionCard(
                title: 'Feedback',
                icon: Icons.feedback,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _interview.feedback!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isUpcoming, canConfirm),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    switch (_interview.status) {
      case InterviewStatus.scheduled:
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case InterviewStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case InterviewStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case InterviewStatus.rescheduled:
        color = Colors.orange;
        icon = Icons.update;
        break;
      case InterviewStatus.noShow:
        color = Colors.grey;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            _interview.status.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notification_important,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interview Starting Soon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Starts in ${_interview.timeUntilString}',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(bool isUpcoming, bool canJoin) {
    // Show review button for completed interviews
    if (_interview.status == InterviewStatus.completed) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteCompanyReviewScreen(
                    companyId: 'comp_${_interview.jobId}',
                    companyName: _interview.companyName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Write Company Review'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      );
    }
    
    // Show join button for upcoming interviews
    if (isUpcoming) {
      return _buildBottomButton(canJoin);
    }
    
    return null;
  }

  Widget _buildBottomButton(bool canConfirm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: canConfirm ? _confirmInterview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canConfirm ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: Icon(canConfirm ? Icons.check_circle : Icons.check_circle_outline),
            label: Text(
              canConfirm ? 'Confirm Interview' : 'Already Confirmed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmInterview() async {
    try {
      await _interviewService.confirmInterview(_interview.id);
      
      if (mounted) {
        setState(() {
          _interview = _interview.copyWith(confirmed: true);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Interview confirmed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm interview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showRescheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Interview'),
        content: const Text(
          'Contact the employer to reschedule this interview. Would you like to send a reschedule request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reschedule request sent')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Interview'),
        content: const Text(
          'Are you sure you want to cancel this interview? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              _interviewService.cancelInterview(_interview.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Interview cancelled')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
