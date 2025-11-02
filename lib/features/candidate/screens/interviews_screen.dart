import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/interview_model.dart';
import 'package:itjobhub/services/interview_service.dart';
import 'package:itjobhub/features/candidate/screens/interview_detail_screen.dart';

/// Interviews Screen
/// Shows list of upcoming and past interviews with tabs
class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> with SingleTickerProviderStateMixin {
  final InterviewService _interviewService = InterviewService();
  late TabController _tabController;
  List<Interview> _upcomingInterviews = [];
  List<Interview> _pastInterviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInterviews();
    _interviewService.addListener(_onInterviewsChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interviewService.removeListener(_onInterviewsChanged);
    super.dispose();
  }

  void _onInterviewsChanged() {
    if (mounted) {
      _loadInterviews();
    }
  }

  Future<void> _loadInterviews() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch interviews from API
      await _interviewService.fetchInterviews();
      
      setState(() {
        _upcomingInterviews = _interviewService.getUpcomingInterviews();
        _pastInterviews = _interviewService.getPastInterviews();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ InterviewsScreen: Failed to load interviews - $e');
      setState(() {
        _upcomingInterviews = [];
        _pastInterviews = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshInterviews() async {
    await _loadInterviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Interviews'),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Upcoming'),
                      if (_upcomingInterviews.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_upcomingInterviews.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Past'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Interviews Tab
          _buildUpcomingTab(),
          
          // Past Interviews Tab
          _buildPastTab(),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upcomingInterviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Upcoming Interviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your scheduled interviews will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshInterviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingInterviews.length,
        itemBuilder: (context, index) {
          final interview = _upcomingInterviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InterviewCard(
              interview: interview,
              onTap: () => _navigateToDetail(interview),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPastTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pastInterviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Past Interviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your interview history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshInterviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pastInterviews.length,
        itemBuilder: (context, index) {
          final interview = _pastInterviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InterviewCard(
              interview: interview,
              onTap: () => _navigateToDetail(interview),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Interview interview) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterviewDetailScreen(interview: interview),
      ),
    );
  }
}

/// Interview Card Widget
class _InterviewCard extends StatelessWidget {
  final Interview interview;
  final VoidCallback onTap;

  const _InterviewCard({
    required this.interview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = interview.status == InterviewStatus.scheduled &&
        interview.scheduledAt.isAfter(DateTime.now());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUpcoming && interview.isWithin24Hours
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey[200]!,
            width: isUpcoming && interview.isWithin24Hours ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with company logo and status
              Row(
                children: [
                  // Company Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        interview.companyLogo,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Job Title and Company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interview.jobTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          interview.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  _StatusBadge(status: interview.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date, Time, and Type
              Row(
                children: [
                  // Date
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.calendar_today,
                      label: interview.formattedDate,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Time
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.access_time,
                      label: interview.formattedTime,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Type and Duration
              Row(
                children: [
                  // Interview Type
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.video_call,
                      label: interview.type.displayName,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Duration
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.timer,
                      label: '${interview.durationMinutes} min',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              
              // Urgent Badge for interviews within 24 hours
              if (isUpcoming && interview.isWithin24Hours) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notification_important,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Starts in ${interview.timeUntilString}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final InterviewStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
