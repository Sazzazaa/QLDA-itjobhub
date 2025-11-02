import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/interview_model.dart';
import '../../../services/interview_service.dart';
import '../../../widgets/common/notification_icon_button.dart';
import 'interview_detail_screen.dart';

class InterviewListScreen extends StatefulWidget {
  const InterviewListScreen({super.key});

  @override
  State<InterviewListScreen> createState() => _InterviewListScreenState();
}

class _InterviewListScreenState extends State<InterviewListScreen>
    with SingleTickerProviderStateMixin {
  final InterviewService _interviewService = InterviewService();
  late TabController _tabController;
  List<Interview> _allInterviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInterviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInterviews() async {
    setState(() => _isLoading = true);
    try {
      print('📅 InterviewListScreen: Loading interviews...');
      final interviews = await _interviewService.fetchInterviews();
      setState(() {
        _allInterviews = interviews;
        _isLoading = false;
      });
      print('✅ InterviewListScreen: Loaded ${interviews.length} interviews');
    } catch (e) {
      print('❌ InterviewListScreen: Failed to load - $e');
      setState(() {
        _allInterviews = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load interviews: $e')),
        );
      }
    }
  }

  List<Interview> get _upcomingInterviews {
    final now = DateTime.now();
    return _allInterviews
        .where((i) =>
            i.scheduledAt.isAfter(now) &&
            i.status == InterviewStatus.scheduled)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<Interview> get _pastInterviews {
    final now = DateTime.now();
    return _allInterviews
        .where((i) =>
            i.scheduledAt.isBefore(now) ||
            i.status == InterviewStatus.completed ||
            i.status == InterviewStatus.cancelled)
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Interviews',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          NotificationIconButton(iconColor: Colors.white),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Upcoming'),
                  if (_upcomingInterviews.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_upcomingInterviews.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Past'),
                  if (_pastInterviews.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pastInterviews.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadInterviews(),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInterviewList(_upcomingInterviews, isUpcoming: true),
                  _buildInterviewList(_pastInterviews, isUpcoming: false),
                ],
              ),
            ),
    );
  }

  Widget _buildInterviewList(List<Interview> interviews,
      {required bool isUpcoming}) {
    if (interviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming interviews'
                  : 'No past interviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Your scheduled interviews will appear here'
                  : 'Completed interviews will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: interviews.length,
      itemBuilder: (context, index) {
        final interview = interviews[index];
        return _buildInterviewCard(interview, isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildInterviewCard(Interview interview, {required bool isUpcoming}) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');

    Color statusColor;
    IconData statusIcon;
    switch (interview.status) {
      case InterviewStatus.scheduled:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case InterviewStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case InterviewStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case InterviewStatus.rescheduled:
        statusColor = Colors.orange;
        statusIcon = Icons.update;
        break;
      case InterviewStatus.noShow:
        statusColor = Colors.grey;
        statusIcon = Icons.person_off;
        break;
    }

    final bool isWithin24Hours = interview.scheduledAt
        .difference(DateTime.now())
        .inHours
        .abs() < 24;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InterviewDetailScreen(interview: interview),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interview.jobTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          interview.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          interview.status.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isWithin24Hours && isUpcoming
                        ? Colors.orange
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(interview.scheduledAt),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isWithin24Hours && isUpcoming
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isWithin24Hours && isUpcoming
                          ? Colors.orange
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isWithin24Hours && isUpcoming
                        ? Colors.orange
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeFormat.format(interview.scheduledAt),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isWithin24Hours && isUpcoming
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isWithin24Hours && isUpcoming
                          ? Colors.orange
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getInterviewTypeColor(interview.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getInterviewTypeIcon(interview.type),
                          size: 14,
                          color: _getInterviewTypeColor(interview.type),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getInterviewTypeLabel(interview.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getInterviewTypeColor(interview.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${interview.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isWithin24Hours && isUpcoming) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Interview starting soon! Make sure you\'re prepared.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  String _getInterviewTypeLabel(InterviewType type) {
    switch (type) {
      case InterviewType.online:
        return 'Online';
      case InterviewType.onsite:
        return 'On-site';
    }
  }
}
